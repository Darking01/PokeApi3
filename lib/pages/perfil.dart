import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_login.dart';
import '../services/firestore_service.dart';
import 'login.dart';
import 'account_option.dart';

class PerfilPage extends StatefulWidget {
  final int favoritosCount;
  const PerfilPage({Key? key, this.favoritosCount = 0}) : super(key: key);

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  User? user = FirebaseAuth.instance.currentUser;
  File? _imageFile;
  bool _loading = false;

  String _username = '';
  String _email = '';
  String? _photoUrl;
  int _favoritosCount = 0;

  final UserFirestoreService _userService = UserFirestoreService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await _userService.getUserData();
    if (data != null) {
      setState(() {
        _username = data['username'] ?? '';
        _email = data['email'] ?? '';
        _photoUrl = data['photoUrl'];
        _favoritosCount = data['favoritosCount'] ?? 0;
      });
    }
  }

  Future<void> _logout() async {
    await authService.value.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _username.isNotEmpty
        ? _username
        : (user?.displayName ?? 'Sin nombre');
    final email = _email.isNotEmpty ? _email : (user?.email ?? 'Sin correo');
    final photoUrl = _photoUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 60,
                backgroundImage: photoUrl != null
                    ? NetworkImage(photoUrl)
                    : null,
                child: (photoUrl == null)
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
              const SizedBox(height: 24),
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                email,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Actualizar datos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(180, 48),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AccountOptionPage(favoritosCount: _favoritosCount),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.red),
                  title: const Text('Pokemones favoritos'),
                  trailing: Text(
                    _favoritosCount.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar sesión'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(180, 48),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
