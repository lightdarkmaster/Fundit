import 'package:flutter/material.dart';
import 'package:fundit/pages/instructions.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.my_library_books,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.lightBlue,
            ),
            tooltip: 'How to Use This App',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InstructionsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(
                  0.3,
                ), // adjust opacity here (0.0 to 1.0)
                BlendMode.darken, // makes image darker with opacity
              ),
              child: Image.asset('assets/images/fundit.png', fit: BoxFit.cover),
            ),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Title
                  Card(
                    // color: Colors.white.withOpacity(0.9),
                    color: Theme.of(context).colorScheme.surface,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'FundIt',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.lightBlue.shade800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your Personal Savings & Goal Tracker',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors
                                    .grey
                                    .shade700, // readable on white card
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sections with Cards
                  _buildCardSection(
                    imagePath: 'assets/images/mobile.jpg',
                    title: 'About the App',
                    description:
                        'FundIt is a personal finance app designed to help users track their savings goals easily. '
                        'Users can create goals, set target amounts, track their progress, and view history of their savings and updates.',
                  ),
                  _buildCardSection(
                    imagePath: 'assets/images/chan.jpg',
                    title: 'Developer',
                    description:
                        'This app was developed by Christian Barbosa, a passionate Flutter developer dedicated to creating user-friendly mobile applications.',
                  ),
                  _buildCardSection(
                    imagePath: 'assets/images/tech.jpg',
                    title: 'Technologies Used',
                    description:
                        '• Flutter & Dart\n'
                        '• SQLite Database for local storage\n'
                        '• intl package for date and number formatting\n'
                        '• image_picker for selecting photos\n'
                        '• sqflite for database operations\n'
                        '• Custom widgets and state management using StatefulWidget',
                  ),
                  _buildCardSection(
                    imagePath: 'assets/images/december-28-2025@2x.png',
                    title: 'App Creation Date',
                    description:
                        'FundIt was initially created on December 28, 2025.',
                  ),
                  const SizedBox(height: 24),

                  // Closing Note
                  Center(
                    child: Text(
                      'Thank you for using FundIt! We hope it helps you achieve your financial goals.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection({
    required String imagePath,
    required String title,
    required String description,
  }) {
    return Card(
      color: Theme.of(context).colorScheme.surface,

      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(imagePath, height: 180, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
