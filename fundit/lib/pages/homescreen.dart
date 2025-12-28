import 'package:flutter/material.dart';
import 'package:fundit/pages/dashboard.dart';
import 'package:fundit/pages/db_helper.dart';
import 'package:fundit/pages/goal_model.dart';
import 'package:path/path.dart';
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
    // Open AddGoalPage with existing goal data
    final updated = await Navigator.push<Goal?>(
      context as BuildContext,
      MaterialPageRoute(builder: (_) => AddGoalPage()),
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
        // centerTitle: true,
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
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Open AddGoalPage without passing a goal (for creating new)
          await Navigator.push<Goal?>(
            context,
            MaterialPageRoute(builder: (_) => AddGoalPage()),
          );
          await _loadGoals();
        },
        icon: const Icon(
          Icons.add,
          color: Colors.white, // Set the icon color here
        ),
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

                // Select color based on index for uniqueness
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${goal.name} (₱ ${pesoFormatter.format(goal.price)})',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
                                  backgroundColor: progressColor.withOpacity(
                                    0.3,
                                  ),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Saved: '),
                              Text(
                                '₱${pesoFormatter.format(goal.saved)}',
                                style: const TextStyle(color: Colors.green),
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
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
