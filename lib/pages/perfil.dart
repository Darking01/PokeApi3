import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_login.dart';
import '../services/firestore_service.dart';
import 'login.dart';
import 'account_option.dart';
import '../utility/custom_loader.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PerfilPage extends StatefulWidget {
  final int favoritosCount;
  const PerfilPage({Key? key, this.favoritosCount = 0}) : super(key: key);

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  User? user = FirebaseAuth.instance.currentUser;
  bool _loading = false;

  String _username = '';
  String _email = '';
  String? _photoUrl;
  int _favoritosCount = 0;
  Color _typeColor = Colors.grey.shade300;

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

  final UserFirestoreService _userService = UserFirestoreService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _loading = true);
    final data = await _userService.getUserData();
    if (data != null) {
      _username = data['username'] ?? '';
      _email = data['email'] ?? '';
      _photoUrl = data['photoUrl'];
      _favoritosCount = data['favoritosCount'] ?? 0;
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

  Future<void> _logout() async {
    setState(() => _loading = true);
    await authService.value.signOut();
    if (mounted) {
      setState(() => _loading = false);
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
      body: _loading
          ? const CustomLoader(message: 'Cargando perfil...')
          : Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
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
                        backgroundImage: photoUrl != null
                            ? NetworkImage(photoUrl)
                            : null,
                        child: (photoUrl == null)
                            ? const Icon(Icons.person, size: 80)
                            : null,
                        backgroundColor: Colors.transparent,
                      ),
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
                    Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 8,
                      ),
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
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Actualizar datos'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(180, 48),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccountOptionPage(
                              favoritosCount: _favoritosCount,
                            ),
                          ),
                        );
                        if (result == true) {
                          await _loadUserData();
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
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
