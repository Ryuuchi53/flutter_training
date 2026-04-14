import 'package:flutter/material.dart';
import 'package:flutter_training_full/app_drawer.dart';

class MenuScreen extends StatelessWidget {
  final String email;
  final String name;

  const MenuScreen({super.key, required this.email, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),

      /// ✅ REUSABLE DRAWER
      drawer: AppDrawer(currentRoute: '/menu', prefilledEmail: email, prefilledName: name),

      /// 🌈 BODY
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF8E2DE2), Color(0xFFDA22FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            'Home Screen ✨\nOpen the menu ☰',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }
}