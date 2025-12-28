import 'package:flutter/material.dart';
import 'package:fundit/pages/about_page.dart';
import 'package:fundit/pages/dashboard.dart';
import 'package:fundit/pages/db_helper.dart';
import 'package:fundit/pages/goal_model.dart';
import 'package:fundit/pages/history_entry_model.dart';
import 'package:fundit/pages/history_page.dart';
import 'add_goal_page.dart';
import 'goal_detail_page.dart';
import 'package:intl/intl.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  List<Goal> goals = [];
  List<HistoryEntry> history = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Goals'),
        actions: [
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

      // Use Stack to add background image
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: Image.asset('assets/images/fundit.png', fit: BoxFit.cover),
          ),

          // Optional overlay for readability
          Container(
            color: Colors.white.withOpacity(0.85),
            child: goals.isEmpty
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
                      final progress = (goal.saved / goal.price).clamp(
                        0.0,
                        1.0,
                      );

                      final progressColor =
                          progressColors[index % progressColors.length];
                      final percentColor =
                          percentageColors[index % percentageColors.length];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
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
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${goal.name} (₱ ${pesoFormatter.format(goal.price)})',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _editGoal(goal);
                                        } else if (value == 'delete') {
                                          _deleteGoal(goal.id!);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Progress bar with unique color and percentage
                                Row(
                                  children: [
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 8,
                                        borderRadius: BorderRadius.circular(8),
                                        backgroundColor: progressColor
                                            .withOpacity(0.3),
                                        color: progressColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${(progress * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: percentColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Saved: '),
                                    Text(
                                      '₱${pesoFormatter.format(goal.saved)}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                      ),
                                    ),
                                    Text('Remaining: '),
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
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
