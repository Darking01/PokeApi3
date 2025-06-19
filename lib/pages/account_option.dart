import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/auth_login.dart';
import '../services/firestore_service.dart';
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
  File? _imageFile;
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    final userId = user?.uid;
    if (userId == null) return null;
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('$userId.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> _saveChanges() async {
    setState(() => _loading = true);
    try {
      String? photoUrl = _photoUrl;

      // Subir imagen si hay una nueva seleccionada
      if (_imageFile != null) {
        photoUrl = await _uploadImage(_imageFile!);
      }

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

      // Actualizar datos en Firestore (nombre, correo, foto)
      await _userService.saveUserData(
        username: _nameController.text.trim(),
        email: _emailController.text.trim(),
        photoUrl: photoUrl,
      );

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
    final displayImage = _imageFile != null
        ? FileImage(_imageFile!)
        : (_photoUrl != null ? NetworkImage(_photoUrl!) : null)
              as ImageProvider<Object>?;

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
                        icon: const Icon(Icons.camera_alt, color: Colors.blue),
                        onPressed: _pickImage,
                        tooltip: 'Cambiar imagen',
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
