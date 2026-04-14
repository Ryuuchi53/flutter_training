import 'package:flutter/material.dart';
import 'package:flutter_training_full/login_screen.dart';
import 'package:flutter_training_full/menu_screen.dart';
import 'package:flutter_training_full/register_screen.dart';
import 'package:flutter_training_full/splash_screen.dart';
import 'package:flutter_training_full/to_do_list_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/menu': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;

          final email = args?['email'] ?? 'user@email.com';
          final name = args?['name'] ?? 'User';

          return MenuScreen(email: email, name: name);
        },
        '/todos': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;

          final email = args?['email'] ?? 'user@email.com';
          final name = args?['name'] ?? 'User';

          return ToDoListScreen(email: email, name: name);
        },
      },
      home: const SplashScreen(),
    );
  }
}
