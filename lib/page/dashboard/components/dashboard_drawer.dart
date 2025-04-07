import 'package:flutter/material.dart';
import 'package:mavale/services/supabase_service.dart';

class DashboardDrawer extends StatelessWidget {
  final String projectId;

  const DashboardDrawer({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Menu'),
          ),
          ListTile(
            title: const Text('Tareas'),
            onTap: () async {
              try {
                final todos = await supabase
                    .from('todos')
                    .select('id, created_at, project_id, title, content, is_completed, due_date, assigned_to, assigned_at')
                    .eq('project_id', projectId)
                    .order('created_at', ascending: false);

                // Close the drawer
                Navigator.pop(context);

                // Show the tasks in the dashboard
                Navigator.pushNamed(
                  context,
                  '/dashboard/tasks',
                  arguments: {
                    'todos': todos,
                    'projectId': projectId,
                  },
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error loading tasks: $e')),
                );
              }
            },
          ),
          ListTile(
            title: const Text('Option 2'),
            onTap: () {
              // Handle option 2
            },
          ),
        ],
      ),
    );
  }
}