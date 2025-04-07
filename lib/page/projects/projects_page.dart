import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'components/projects_card.dart';
import 'components/projects_form_dialog.dart';
import 'package:mavale/services/projects/projects_service.dart';
import '../../widgets/menu_scaffold.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late final ProjectService _projectService;
  late Future<List<Map<String, dynamic>>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _projectService = ProjectService(Supabase.instance.client);
    _projectsFuture = _projectService.fetchProjects();
  }

  Future<void> _createNewProject() async {
    final result = await showDialog(
      context: context,
      builder: (context) => ProjectFormDialog(
        onSubmit: (name, description) async {
          final userId = Supabase.instance.client.auth.currentUser?.id;
          if (userId == null) return;

          await _projectService.createProject({
            'name': name,
            'description': description,
            'owner_id': userId,
          });
        },
      ),
    );

    if (result == true) {
      setState(() {
        _projectsFuture = _projectService.fetchProjects();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MenuScaffold(
        title: 'Projects',
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _projectsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _projectsFuture = _projectService.fetchProjects();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No projects found. Create one to get started!'),
              );
            }

            final projects = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _projectsFuture = _projectService.fetchProjects();
                });
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  return ProjectCard(project: projects[index], index:index);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewProject,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}