import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fundit/pages/about_page.dart';
import 'package:fundit/pages/dashboard.dart';
import 'package:fundit/db/db_helper.dart';
import 'package:fundit/models/goal_model.dart';
import 'package:fundit/models/history_entry_model.dart';
import 'package:fundit/pages/history_page.dart';
import 'add_goal_page.dart';
import 'goal_detail_page.dart';
import 'package:intl/intl.dart';

class Homescreen extends StatefulWidget {
  final dynamic themeController;

  // const Homescreen({super.key});
  const Homescreen({super.key, required this.themeController});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  List<Goal> goals = [];
  List<HistoryEntry> history = [];
  String truncateWithEllipsis(int cutoff, String myString) {
    return (myString.length <= cutoff)
        ? myString
        : '${myString.substring(0, cutoff)}…';
  }

  // Define color palettes
  final progressColors = [
    Colors.lightBlue,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.teal,
  ];
  final percentageColors = [
    Colors.cyan,
    Colors.deepOrange,
    Colors.lightGreen,
    Colors.purpleAccent,
    Colors.tealAccent,
  ];

  static final NumberFormat pesoFormatter = NumberFormat('#,##0.00', 'en_PH');

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    goals = await DBHelper.instance.fetchGoals();
    setState(() {});
  }

  void _deleteGoal(int id) async {
    await DBHelper.instance.deleteGoal(id);
    await _loadGoals();
  }

  void _editGoal(Goal goal) async {
    final updated = await Navigator.push<Goal?>(
      context,
      MaterialPageRoute(builder: (_) => AddGoalPage(goal: goal)),
    );

    if (updated != null) {
      await _loadGoals();
    }
  }

  Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.orangeAccent;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Goals'),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: widget.themeController.themeNotifier,
            builder: (context, mode, _) {
              return IconButton(
                icon: Icon(
                  mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.lightBlue,
                ),
                onPressed: () {
                  widget.themeController.toggleTheme();
                },
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.lightBlue),
            tooltip: 'Go to Dashboard',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DashboardPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.lightBlue),
            tooltip: 'Go to History Page',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info, color: Colors.lightBlue),
            tooltip: 'Go to About Page',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newGoal = await Navigator.push<Goal?>(
            context,
            MaterialPageRoute(builder: (_) => const AddGoalPage()),
          );

          if (newGoal != null) {
            await _loadGoals();
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Goal', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
      ),
      body: goals.isEmpty
          ? const Center(
              child: Text(
                'No goals yet\nStart saving today',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: goals.length,
              itemBuilder: (_, index) {
                final goal = goals[index];
                final progress = (goal.saved / goal.price).clamp(0.0, 1.0);
                final progressColor =
                    progressColors[index % progressColors.length];
                // final percentColor =
                //     percentageColors[index % percentageColors.length];

                final colorScheme = Theme.of(context).colorScheme;
                final isDarkMode =
                    Theme.of(context).brightness == Brightness.dark;

                return Stack(
                  children: [
                    Card(
                      color: colorScheme.surface,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: isDarkMode
                            ? BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                                width: 1,
                              )
                            : BorderSide.none,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          final updated = await Navigator.push<Goal?>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GoalDetailPage(goal: goal),
                            ),
                          );
                          if (updated != null) {
                            await _loadGoals();
                          }
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: 160,
                          child: Stack(
                            children: [
                              // Background image
                              if (goal.imagePath != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Opacity(
                                    opacity:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? 0.05
                                        : 0.09,
                                    child: Image.file(
                                      File(goal.imagePath!),
                                      width: double.infinity,
                                      height: 160,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),

                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10),

                                    // Goal name
                                    Text(
                                      truncateWithEllipsis(
                                        20, // max number of characters
                                        '${goal.name} (₱ ${pesoFormatter.format(goal.price)})',
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurface,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    const SizedBox(height: 8),

                                    // Progress bar + percentage
                                    Row(
                                      children: [
                                        Expanded(
                                          child: LinearProgressIndicator(
                                            value: progress,
                                            minHeight: 8,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            backgroundColor:
                                                Colors.grey.shade300,
                                            color: progressColor,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colorScheme
                                                .surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            '${(progress * 100).toStringAsFixed(0)}%',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // Saved & Remaining
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Saved:',
                                          style: TextStyle(
                                            color: colorScheme.onSurface,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '₱${pesoFormatter.format(goal.saved)}',
                                          style: const TextStyle(
                                            color: Colors.green,
                                          ),
                                        ),
                                        Text(
                                          'Remaining:',
                                          style: TextStyle(
                                            color: colorScheme.onSurface,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '₱${pesoFormatter.format(goal.remaining)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),

                                    if (goal.createdAt != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          'Created: ${DateFormat('MMMM d, y (EEEE, hh:mma)').format(goal.createdAt!).toLowerCase()}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Priority banner
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: getPriorityColor(goal.priority ?? ''),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                        ),
                        child: Text(
                          (goal.priority ?? '').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Edit / Delete menu
                    Positioned(
                      right: 5,
                      top: 20,
                      child: PopupMenuButton<String>(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editGoal(goal);
                          } else if (value == 'delete') {
                            _deleteGoal(goal.id!);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
