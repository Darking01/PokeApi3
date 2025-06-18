import 'package:flutter/material.dart';
import 'login.dart';

class InicioPage extends StatelessWidget {
  const InicioPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Al construir esta página, navega inmediatamente a la pantalla de login
    Future.microtask(() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });

    // Mientras navega, muestra una pantalla de carga simple
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
