import 'package:flutter/material.dart';

class DashboardContent extends StatelessWidget {
  final Map<String, dynamic> project;
  final int index;
  final String createdAt;
  final String createdTime;
  final String username;

  const DashboardContent({
    super.key,
    required this.project,
    required this.index,
    required this.createdAt,
    required this.createdTime,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${project['name']}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text('Index: $index'),
          const SizedBox(height: 20),
          Text('Creado: $createdAt a las $createdTime'),
          const SizedBox(height: 20),
          Text('Propietario: $username'),
        ],
      ),
    );
  }
}