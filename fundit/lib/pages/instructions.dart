import 'package:flutter/material.dart';

class InstructionsPage extends StatefulWidget {
  const InstructionsPage({super.key});

  @override
  State<InstructionsPage> createState() => _InstructionsPageState();
}

class _InstructionsPageState extends State<InstructionsPage> {
  // Sample instructions
  final List<Map<String, String>> steps = [
    {
      'title': 'Add a Goal',
      'description':
          'Tap the "+" button to add a new goal. Enter the name, target amount, and optional image.',
    },
    {
      'title': 'Track Progress',
      'description':
          'Update your saved amount regularly to track your progress toward your goal.',
    },
    {
      'title': 'View Dashboard',
      'description':
          'Check the dashboard to see your overall progress and analytics of all your goals.',
    },
    {
      'title': 'Edit or Delete Goals',
      'description':
          'Tap on a goal to view details, edit information, or delete it if no longer needed.',
    },
    {
      'title': 'Change Theme',
      'description':
          'Use the theme toggle in the top-right corner to switch between light and dark mode.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How to Use Fundit'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final step = steps[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.transparent,
                width: 0.5,
              ),
            ),
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.surface
                : Colors.blue.shade50,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.deepPurple,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step['title']!,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step['description']!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
