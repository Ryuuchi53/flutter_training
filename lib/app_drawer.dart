import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;
  final String? prefilledEmail;
  final String? prefilledName;

  const AppDrawer({
    super.key,
    required this.currentRoute,
    this.prefilledEmail,
    this.prefilledName,
  });

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context);

    if (currentRoute == route) return;

    Navigator.of(context).pushNamed(
      route,
      arguments: {'email': prefilledEmail ?? 'user@email.com', 'name': prefilledName ?? 'User'},
    );
  }

  void _logout(BuildContext context) {
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out 👋', textAlign: TextAlign.center),
      ),
    );

    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF8E2DE2), Color(0xFFDA22FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              /// HEADER
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Welcome Back 👋',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      prefilledName ?? 'User Name',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      prefilledEmail ?? 'user@email.com',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// NAV ITEMS
              _item(context, Icons.home_rounded, 'Menu', '/menu'),
              _item(context, Icons.check_circle_outline, 'To-Do', '/todos'),
              _item(context, Icons.person_outline, 'Profile', '/profile'),
              _item(context, Icons.settings_outlined, 'Settings', '/settings'),

              const Spacer(),

              /// LOGOUT (WHITE CARD)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    onTap: () => _logout(context),
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: Colors.redAccent,
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// NAV ITEM WITH ACTIVE STATE 🔥
  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    final isActive = currentRoute == route;

    return ListTile(
      onTap: () => _navigate(context, route),
      leading: Icon(icon, color: isActive ? Colors.amber : Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.amber : Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      tileColor: isActive ? Colors.white.withValues(alpha: 0.1) : null,
    );
  }
}
