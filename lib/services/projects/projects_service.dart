import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectService {
  final SupabaseClient _supabase;

  ProjectService(this._supabase);

  Future<List<Map<String, dynamic>>> fetchProjects() async {
    try {
      final response = await _supabase
          .from('projects')
          .select('*, profiles:owner_id(username)');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error fetching projects: $e');
    }
  }

  Future<void> createProject(Map<String, dynamic> projectData) async {
    try {
      await _supabase.from('projects').insert(projectData);
    } catch (e) {
      throw Exception('Error creating project: $e');
    }
  }
}