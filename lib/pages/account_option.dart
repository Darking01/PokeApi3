import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../services/auth_login.dart';
import '../services/firestore_service.dart';
import 'perfil.dart';
import 'login.dart';
import '../utility/custom_loader.dart';

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
  Color _typeColor = Colors.grey.shade300;

  final UserFirestoreService _userService = UserFirestoreService();

  static const Map<String, Color> typeBgColors = {
    'normal': Color(0xFFA8A77A),
    'fire': Color(0xFFEE8130),
    'water': Color(0xFF6390F0),
    'electric': Color(0xFFF7D02C),
    'grass': Color(0xFF7AC74C),
    'ice': Color(0xFF96D9D6),
    'fighting': Color(0xFFC22E28),
    'poison': Color(0xFFA33EA1),
    'ground': Color(0xFFE2BF65),
    'flying': Color(0xFFA98FF3),
    'psychic': Color(0xFFF95587),
    'bug': Color(0xFFA6B91A),
    'rock': Color(0xFFB6A136),
    'ghost': Color(0xFF735797),
    'dragon': Color(0xFF6F35FC),
    'dark': Color(0xFF705746),
    'steel': Color(0xFFB7B7CE),
    'fairy': Color(0xFFD685AD),
  };

  @override
  void initState() {
    super.initState();
    _nameController.text = user?.displayName ?? '';
    _emailController.text = user?.email ?? '';
    _loadFirestoreData();
  }

  Future<void> _loadFirestoreData() async {
    setState(() => _loading = true);
    final data = await _userService.getUserData();
    if (data != null && data['photoUrl'] != null) {
      _photoUrl = data['photoUrl'];
      await _loadTypeColor(_photoUrl);
    }
    setState(() => _loading = false);
  }

  Future<void> _loadTypeColor(String? photoUrl) async {
    if (photoUrl == null) {
      setState(() => _typeColor = Colors.grey.shade300);
      return;
    }
    final regex = RegExp(r'/(\d+)\.png');
    final match = regex.firstMatch(photoUrl);
    if (match != null) {
      final pokeId = match.group(1);
      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon/$pokeId'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final types = data['types'] as List;
        if (types.isNotEmpty) {
          final type = types[0]['type']['name'];
          setState(() {
            _typeColor = typeBgColors[type] ?? Colors.grey.shade300;
          });
          return;
        }
      }
    }
    setState(() => _typeColor = Colors.grey.shade300);
  }

  void _setRandomPokemonAvatar() async {
    setState(() {
      _photoUrl = getRandomPokemonImageUrl();
    });
    await _loadTypeColor(_photoUrl);
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
      body: _loading
          ? const CustomLoader(message: 'Cargando...')
          : Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          // Avatar grande con fondo de color según tipo
                          Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              color: _typeColor,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 80,
                              backgroundImage: displayImage,
                              child: (displayImage == null)
                                  ? const Icon(Icons.person, size: 80)
                                  : null,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: IconButton(
                              icon: const Icon(
                                Icons.casino,
                                color: Colors.blue,
                              ),
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
                        enabled: false,
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
                      ElevatedButton.icon(
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
