import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fundit/pages/goal_model.dart';
import 'package:fundit/pages/db_helper.dart';
import 'package:intl/intl.dart';

class GoalDetailPage extends StatefulWidget {
  final Goal goal;

  const GoalDetailPage({super.key, required this.goal});

  @override
  State<GoalDetailPage> createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends State<GoalDetailPage> {
  static final NumberFormat pesoFormatter = NumberFormat('#,##0.00', 'en_PH');
  late Goal goal;

  @override
  void initState() {
    super.initState();
    goal = widget.goal;
  }

  @override
  Widget build(BuildContext context) {
    final progress = (goal.saved / goal.price).clamp(0.0, 1.0);
    final progressPercentage = (progress * 100).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(title: const Text('Goal Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Goal Image
                    if (goal.imagePath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(goal.imagePath!),
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '$progressPercentage%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.cyan,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(10),
                          backgroundColor: const Color.fromARGB(
                            255,
                            159,
                            222,
                            238,
                          ),
                          color: Colors.lightBlue,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _row('Price', goal.price),
                    _row('Saved', goal.saved),
                    const Divider(height: 32),
                    _row('Remaining', goal.remaining, highlight: true),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Button color
                          foregroundColor: Colors.white, // Text color
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ), // Optional: increase height
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // Rounded corners
                          ),
                        ),
                        onPressed: () => _showAddSavingsDialog(context),
                        child: const Text('Add Savings'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, double value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '₱ ${pesoFormatter.format(value)}',
            style: TextStyle(
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: highlight ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSavingsDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Savings'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: '₱ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final addAmount = double.tryParse(controller.text);
              if (addAmount != null && addAmount > 0) {
                final updatedGoal = Goal(
                  id: goal.id,
                  name: goal.name,
                  price: goal.price,
                  saved: goal.saved + addAmount,
                  imagePath: goal.imagePath,
                );

                await DBHelper.instance.updateGoal(updatedGoal);

                // Refresh the current goal from the database
                final goals = await DBHelper.instance.fetchGoals();
                final refreshedGoal = goals.firstWhere((g) => g.id == goal.id);
                setState(() {
                  goal = refreshedGoal;
                });

                Navigator.pop(context); // Close dialog
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
