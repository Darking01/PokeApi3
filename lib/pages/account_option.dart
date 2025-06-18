import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_login.dart';
import 'perfil.dart';

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

  @override
  void initState() {
    super.initState();
    _nameController.text = user?.displayName ?? '';
    _emailController.text = user?.email ?? '';
  }

  Future<void> _saveChanges() async {
    setState(() => _loading = true);
    try {
      // Actualizar nombre de usuario
      if (_nameController.text.trim().isNotEmpty &&
          _nameController.text.trim() != user?.displayName) {
        await authService.value.updateUsername(
          username: _nameController.text.trim(),
        );
      }

      // Actualizar correo electrónico
      if (_emailController.text.trim().isNotEmpty &&
          _emailController.text.trim() != user?.email) {
        if (_currentPassController.text.isEmpty) {
          throw Exception(
            'Debes ingresar tu contraseña actual para cambiar el correo.',
          );
        }
        await user?.reauthenticateWithCredential(
          EmailAuthProvider.credential(
            email: user!.email!,
            password: _currentPassController.text,
          ),
        );
        await user?.updateEmail(_emailController.text.trim());
      }

      // Cambiar contraseña
      if (_newPassController.text.isNotEmpty) {
        if (_currentPassController.text.isEmpty) {
          throw Exception(
            'Debes ingresar tu contraseña actual para cambiar la contraseña.',
          );
        }
        await user?.reauthenticateWithCredential(
          EmailAuthProvider.credential(
            email: user!.email!,
            password: _currentPassController.text,
          ),
        );
        await user?.updatePassword(_newPassController.text);
      }

      await user?.reload();
      user = FirebaseAuth.instance.currentUser;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos actualizados correctamente')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PerfilPage(favoritosCount: widget.favoritosCount),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error al actualizar datos')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Actualizar datos')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
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
