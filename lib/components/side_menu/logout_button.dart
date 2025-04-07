// components/logout_button.dart
import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await supabase.auth.signOut();
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst); // Close all routes
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout),
      title: const Text('Logout'),
      onTap: () async {
        Navigator.pop(context); // Close the drawer first
        await _logout(context); // Then perform logout
      },
    );
  }
}