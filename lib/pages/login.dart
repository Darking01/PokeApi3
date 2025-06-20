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
          MaterialPageRoute(builder: (context) => InicioPage()),
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

  void _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa tu correo para recuperar la contraseña'),
        ),
      );
      return;
    }
    try {
      await authService.value.resetPassword(
        email: _emailController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo de recuperación enviado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Imagen de título casi pegada arriba
                  Image.asset(AppImages.title, width: 240, fit: BoxFit.contain),
                  const SizedBox(height: 8),
                  // Imagen de entrenadores
                  Image.asset(
                    AppImages.entrenadores,
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 14),
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
                          margin: const EdgeInsets.only(bottom: 14),
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
                        const SizedBox(height: 8),
                        _loading
                            ? const CustomLoader(message: 'Iniciando sesión...')
                            : ElevatedButton(
                                onPressed: _login,
                                child: const Text('Iniciar sesión'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ),
                        // Puedes descomentar si quieres el botón de recuperar contraseña
                        /*
                        TextButton(
                          onPressed: _resetPassword,
                          child: const Text('¿Olvidaste tu contraseña?'),
                        ),
                        */
                        const SizedBox(height: 8),
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
            child: Image.asset(AppImages.pikaSaludo, width: 180, height: 180),
          ),
        ],
      ),
    );
  }
}
