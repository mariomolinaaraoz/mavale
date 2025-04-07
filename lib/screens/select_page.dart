import 'package:flutter/material.dart';
import '../widgets/menu_scaffold.dart';

class SelectPage extends StatelessWidget {
  const SelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuScaffold(
      title: 'Mavale',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildSectionCard(
                    context: context,
                    image: 'assets/images/todo.jpg',
                    title: 'To-Do',
                    description: 'Organize your tasks\nTrack your daily activities',
                    route: '/todo',
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    context: context,
                    image: 'assets/images/note.jpg',
                    title: 'Notes',
                    description: 'Capture your ideas instantly\nAccess anywhere, anytime',
                    route: '/note',
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    context: context,
                    image: 'assets/images/blog.jpg',
                    title: 'Blogs',
                    description: 'Read latest articles\nShare your knowledge',
                    route: '/blogs',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String image,
    required String title,
    required String description,
    required String route,
  }) {
    final lines = description.split('\n');
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => Navigator.pushNamed(context, route),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Image.asset(
                    image,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((128).round()),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lines[0],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                  Text(
                    lines[1],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}