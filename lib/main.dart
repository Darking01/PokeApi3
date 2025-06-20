import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'pages/login.dart'; // o tu página inicial
import 'firebase_options.dart'; // generado por FlutterFire CLI
import 'utility/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: themeProvider.isDarkMode
                ? Brightness.dark
                : Brightness.light,
            colorSchemeSeed: themeProvider.primaryColor,
            useMaterial3: true,
          ),
          home: const LoginPage(), // o tu página inicial
        );
      },
    );
  }
}
