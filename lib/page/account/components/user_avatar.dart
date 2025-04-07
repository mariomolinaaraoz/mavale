import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final VoidCallback onPressed;

  const UserAvatar({
    super.key,
    required this.avatarUrl,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: CircleAvatar(
        backgroundImage: avatarUrl != null
            ? NetworkImage(avatarUrl!) // Usar la URL de la imagen de perfil
            : null,
        radius: 16,
        child: avatarUrl == null
            ? const Icon(Icons.person) // Muestra un ícono si no hay imagen
            : null,
      ),
      onPressed: onPressed, // Abre el menú lateral
    );
  }
}