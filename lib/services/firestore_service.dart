import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserFirestoreService {
  final _users = FirebaseFirestore.instance.collection('users');

  // Guardar o actualizar datos del usuario (crea el documento si no existe)
  Future<void> saveUserData({
    String? username,
    String? email,
    String? photoUrl,
    int favoritosCount = 0,
    List<String>? favoritos,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _users.doc(user.uid).set({
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'favoritosCount': favoritosCount,
      if (favoritos != null) 'favoritos': favoritos,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Leer datos del usuario
  Future<Map<String, dynamic>?> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final doc = await _users.doc(user.uid).get();
    return doc.data();
  }

  // Actualizar solo la lista de favoritos (crea el documento si no existe)
  Future<void> updateFavoritos(List<String> favoritos) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _users.doc(user.uid).set({
      'favoritos': favoritos,
      'favoritosCount': favoritos.length, // <-- ¡Actualiza el contador!
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Obtener la lista de favoritos
  Future<List<String>> getFavoritos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final doc = await _users.doc(user.uid).get();
    final data = doc.data();
    if (data == null || data['favoritos'] == null) return [];
    return List<String>.from(data['favoritos']);
  }

  // Ejecuta esto una vez en tu app para corregir los datos antiguos
  Future<void> fixFavoritosCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = doc.data();
    if (data != null && data['favoritos'] != null) {
      final favoritos = List<String>.from(data['favoritos']);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'favoritosCount': favoritos.length},
      );
    }
  }
}
