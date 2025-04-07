// components/side_menu.dart
import 'package:flutter/material.dart';
import 'package:mavale/components/side_menu/logout_button.dart'; // Importa el componente de logout

class SideMenu extends StatelessWidget {
  final String? avatarUrl;
  final String? userName;
  final String? userEmail;
  final VoidCallback onAccountPressed;

  const SideMenu({
    super.key,
    required this.avatarUrl,
    required this.userName,
    required this.userEmail,
    required this.onAccountPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl!) // Usar la URL de la imagen de perfil
                      : null,
                  radius: 30,
                  child: avatarUrl == null
                      ? const Icon(Icons.person) // Muestra un ícono si no hay imagen
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  userName ?? 'Usuario', // Muestra el nombre del usuario
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userEmail ?? 'Usuario', // Muestra el email del usuario
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('Mi Perfil'),
            onTap: onAccountPressed, // Navega a /account
          ),
          const LogoutButton(), // Usa el componente reutilizable
        ],
      ),
    );
  }
}