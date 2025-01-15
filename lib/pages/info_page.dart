import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Welcome to HoFax!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Platform for Northeastern Student Ratings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Text(
              'HoFax is a unique platform designed for Northeastern students to rate and view peer ratings across various qualities:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildQualityList(context),
            const SizedBox(height: 24),
            const Text(
              'With HoFax, you can:\n'
              '• View ratings from other students\n'
              '• Add your own ratings\n'
              '• Share ratings with others\n'
              '• Access a comprehensive database of student feedback',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityList(BuildContext context) {
    final qualities = [
      {'name': 'Emotional Intelligence', 'icon': Icons.psychology},
      {'name': 'Values', 'icon': Icons.volunteer_activism},
      {'name': 'Intelligence', 'icon': Icons.lightbulb},
      {'name': 'Vibe', 'icon': Icons.mood},
      {'name': 'Commitment', 'icon': Icons.handshake},
      {'name': 'Stability', 'icon': Icons.balance},
      {'name': 'Attractiveness', 'icon': Icons.favorite},
    ];

    return Column(
      children:
          qualities.map((quality) {
            return ListTile(
              leading: Icon(
                quality['icon'] as IconData,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                quality['name'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
    );
  }
}
