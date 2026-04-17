import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_training_full/utils/shared_preferences_utils.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  void _navigate(BuildContext context, String? route) {
    Navigator.pop(context);

    if (route == null) return;
    if (currentRoute == route) return;

    Navigator.of(context).pushNamed(route);
  }

  void _logout(BuildContext context) async {
    Navigator.pop(context); // close drawer if any

    await SharedPreferencesUtils().clearSharedPreferences();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out 👋', textAlign: TextAlign.center),
      ),
    );

    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final name = SharedPreferencesUtils().getSharedPrefsName;
    final email = SharedPreferencesUtils().getSharedPrefsEmail;

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
                    // CircleAvatar(
                    //   radius: 30,
                    //   backgroundColor: Colors.white,
                    //   child: Icon(Icons.person),
                    // ),
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: SvgPicture.asset(
                          'assets/avatar.svg',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
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
                    Text(name, style: TextStyle(color: Colors.white70)),
                    Text(email, style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// NAV ITEMS
              _item(context, Icons.newspaper_outlined, 'News', '/news'),
              _item(context, Icons.local_movies, 'Films', '/films'),
              _item(context, Icons.check_circle_outline, 'To-Do', '/todos'),
              
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
    String? route,
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
