import 'package:flutter/material.dart';
import 'components/dashboard_drawer.dart';
import 'components/dashboard_content.dart';

class DashboardPage extends StatelessWidget {
  final Map<String, dynamic> project;
  final int index;
  final String createdAt;
  final String createdTime;
  final String username;
  final String projectId;

  const DashboardPage({
    super.key,
    required this.project,
    required this.index,
    required this.createdAt,
    required this.createdTime,
    required this.username,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project['name'] ?? 'Dashboard'),
      ),
      drawer: DashboardDrawer(projectId: projectId),
      body: DashboardContent(
        project: project,
        index: index,
        createdAt: createdAt,
        createdTime: createdTime,
        username: username,
      ),
    );
  }
}