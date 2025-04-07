import 'package:flutter/material.dart';
import 'package:mavale/services/supabase_service.dart';

class TasksPage extends StatefulWidget {
  final String projectId;

  const TasksPage({
    super.key,
    required this.projectId,
  });

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  List<Map<String, dynamic>> _todos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      final data = await supabase
          .from('todos')
          .select()
          .eq('project_id', widget.projectId)
          .order('created_at', ascending: false);

      setState(() {
        _todos = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching tasks: $e')),
      );
    }
  }

  void _addTask(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddTaskDialog(),
    );

    if (result != null) {
      try {
        await supabase.from('todos').insert({
          'title': result['title'],
          'content': result['content'],
          'project_id': widget.projectId,
          'is_completed': false,
          'created_at': DateTime.now().toIso8601String(),
        });

        await _fetchTasks(); // Refresh the task list

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task added successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding task: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final todo = _todos[index];
                return ListTile(
                  title: Text(todo['title']),
                  subtitle: Text(todo['content']),
                  trailing: Checkbox(
                    value: todo['is_completed'],
                    onChanged: (value) {
                      // Handle task completion
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTask(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_titleController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Title is required')),
              );
              return;
            }

            Navigator.pop(context, {
              'title': _titleController.text,
              'content': _contentController.text,
            });
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}