import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_login.dart';
import '../services/firestore_service.dart';
import 'perfil.dart';
import 'login.dart';

String getRandomPokemonImageUrl() {
  final random = Random();
  final pokeId = random.nextInt(898) + 1;
  return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokeId.png';
}

class AccountOptionPage extends StatefulWidget {
  final int favoritosCount;
  const AccountOptionPage({Key? key, this.favoritosCount = 0})
    : super(key: key);

  @override
  State<AccountOptionPage> createState() => _AccountOptionPageState();
}

class _AccountOptionPageState extends State<AccountOptionPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;
  bool _loading = false;
  String? _photoUrl;

  final UserFirestoreService _userService = UserFirestoreService();

  @override
  void initState() {
    super.initState();
    _nameController.text = user?.displayName ?? '';
    _emailController.text = user?.email ?? '';
    _loadFirestoreData();
  }

  Future<void> _loadFirestoreData() async {
    final data = await _userService.getUserData();
    if (data != null && data['photoUrl'] != null) {
      setState(() {
        _photoUrl = data['photoUrl'];
      });
    }
  }

  void _setRandomPokemonAvatar() {
    setState(() {
      _photoUrl = getRandomPokemonImageUrl();
    });
  }

  Future<void> _saveChanges() async {
    setState(() => _loading = true);
    try {
      bool passwordChanged = false;

      // Actualizar nombre de usuario en Auth y Firestore
      if (_nameController.text.trim().isNotEmpty &&
          _nameController.text.trim() != user?.displayName) {
        await authService.value.updateUsername(
          username: _nameController.text.trim(),
        );
      }

      // Actualizar correo electrónico en Auth y Firestore
      if (_emailController.text.trim().isNotEmpty &&
          _emailController.text.trim() != user?.email) {
        if (_currentPassController.text.isEmpty) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Debes ingresar tu contraseña actual para cambiar el correo.',
              ),
            ),
          );
          return;
        }
        try {
          await user?.reauthenticateWithCredential(
            EmailAuthProvider.credential(
              email: user!.email!,
              password: _currentPassController.text,
            ),
          );
        } on FirebaseAuthException catch (e) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error de autenticación: ${e.message}')),
          );
          return;
        }
        await user?.updateEmail(_emailController.text.trim());
      }

      // Cambiar contraseña
      if (_newPassController.text.isNotEmpty) {
        if (_currentPassController.text.isEmpty) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Debes ingresar tu contraseña actual para cambiar la contraseña.',
              ),
            ),
          );
          return;
        }
        try {
          await user?.reauthenticateWithCredential(
            EmailAuthProvider.credential(
              email: user!.email!,
              password: _currentPassController.text,
            ),
          );
        } on FirebaseAuthException catch (e) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error de autenticación: ${e.message}')),
          );
          return;
        }
        try {
          await user?.updatePassword(_newPassController.text);
          passwordChanged = true;
        } on FirebaseAuthException catch (e) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar contraseña: ${e.message}'),
            ),
          );
          return;
        }
      }

      // Actualizar datos en Firestore (nombre, correo, foto)
      await _userService.saveUserData(
        username: _nameController.text.trim(),
        email: _emailController.text.trim(),
        photoUrl: _photoUrl,
      );

      await user?.reload();
      user = FirebaseAuth.instance.currentUser;

      if (mounted) {
        setState(() => _loading = false);
        if (passwordChanged) {
          await authService.value.signOut();
          await Future.delayed(const Duration(milliseconds: 200));
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          }
          // No muestres SnackBar aquí, el contexto ya no existe
          return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Datos actualizados correctamente')),
          );
          Navigator.pop(context, true);
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error al actualizar datos')),
      );
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayImage = _photoUrl != null ? NetworkImage(_photoUrl!) : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Actualizar datos')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: displayImage,
                      child: (displayImage == null)
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: IconButton(
                        icon: const Icon(Icons.casino, color: Colors.blue),
                        onPressed: _setRandomPokemonAvatar,
                        tooltip: 'Avatar aleatorio',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de usuario',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _currentPassController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña actual',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _newPassController,
                  decoration: const InputDecoration(
                    labelText: 'Nueva contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 32),
                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: _saveChanges,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar cambios'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(180, 48),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
