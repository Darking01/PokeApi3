import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_login.dart';
import '../services/firestore_service.dart';
import 'register.dart';
import 'inicio.dart';
import '../utility/image_ui.dart';
import '../utility/custom_loader.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final UserFirestoreService _userService = UserFirestoreService();

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await authService.value.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Recuperar datos del usuario desde Firestore
      final userData = await _userService.getUserData();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InicioPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Error al iniciar sesión';
      if (e.code == 'user-not-found') {
        msg = 'Usuario no encontrado';
      } else if (e.code == 'wrong-password') {
        msg = 'Contraseña incorrecta';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo de pantalla
          Image.asset(AppImages.login, fit: BoxFit.cover),
          // Capa semitransparente opcional para oscurecer el fondo
          Container(color: Colors.black.withOpacity(0.3)),
          // Contenido principal muy arriba
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  screenWidth * 0.06, 0, screenWidth * 0.06, screenWidth * 0.06),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Imagen de título casi pegada arriba
                  Image.asset(
                    AppImages.title,
                    width: screenWidth * 0.6,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  // Imagen de entrenadores
                  Image.asset(
                    AppImages.entrenadores,
                    width: screenWidth * 0.5,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: screenWidth * 0.06),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: screenWidth * 0.03),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.10),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            decoration: _inputDecoration(
                              'Correo electrónico',
                              Icons.email,
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Ingresa tu correo'
                                : null,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: screenWidth * 0.03),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.10),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            decoration: _inputDecoration(
                              'Contraseña',
                              Icons.lock,
                            ),
                            obscureText: true,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Ingresa tu contraseña'
                                : null,
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.02),
                        _loading
                            ? const CustomLoader(message: 'Iniciando sesión...')
                            : ElevatedButton(
                                onPressed: _login,
                                child: const Text('Iniciar sesión'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(double.infinity, screenWidth * 0.12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ),
                        SizedBox(height: screenWidth * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('¿No tienes cuenta?'),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterPage(),
                                  ),
                                );
                              },
                              child: const Text('Regístrate'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Pikachu saludo en la esquina inferior derecha, grande pero no tapa los botones
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              AppImages.pikaSaludo,
              width: screenWidth * 0.35,
              height: screenWidth * 0.35,
            ),
          ),
        ],
      ),
    );
  }
}
