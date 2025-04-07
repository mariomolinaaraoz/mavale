import 'package:flutter/material.dart';
import '../../../services/date_time_service.dart';

class ProjectCard extends StatelessWidget {
  final Map<String, dynamic> project;
  final int index;

  const ProjectCard({super.key, required this.project, required this.index});

  @override
  Widget build(BuildContext context) {
    DateTime? createdAt;
    try {
      final dateString = project['created_at']?.toString() ?? '';
      createdAt = DateTime.tryParse(dateString);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error parsing date: $e')));
    }

    final formattedDate =
        createdAt != null ? DateTimeService.formatDate(createdAt) : 'N/A';
    final formattedTime =
        createdAt != null ? DateTimeService.formatTime(createdAt) : 'N/A';
    final username = project['profiles']?['username'] ?? 'Unknown';

    final colors = [Colors.indigo[50], Colors.teal[50], Colors.amber[50]];
    final backgroundColor =
        colors[index % colors.length] ?? Colors.grey.shade200;
    final textColor =
        backgroundColor.computeLuminance() > 0.5
            ? Colors.black87
            : Colors.white;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/dashboard',
            arguments: {
              'project': project,
              'index': index,
              'createdAt': formattedDate,
              'createdTime': formattedTime,
              'username': username,
              'id': project['id'],
            },
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: backgroundColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project['name'] ?? 'No Name',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project['description'] ?? 'No Description',
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withAlpha(180),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withAlpha(180),
                      ),
                    ),
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
