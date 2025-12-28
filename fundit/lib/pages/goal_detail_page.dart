import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fundit/models/goal_model.dart';
import 'package:fundit/db/db_helper.dart';
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

  Color getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
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
    final progress = (goal.saved / goal.price).clamp(0.0, 1.0);
    final progressPercentage = (progress * 100).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(title: const Text('Goal Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Stack(
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
                    // Goal Image with tap-to-view
                    if (goal.imagePath != null) ...[
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: EdgeInsets.all(10),
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Hero(
                                  tag: 'goalImage-${goal.id}',
                                  child: InteractiveViewer(
                                    panEnabled: true,
                                    minScale: 0.5,
                                    maxScale: 3.0,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(goal.imagePath!),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: 'goalImage-${goal.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(goal.imagePath!),
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
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
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(10),
                      backgroundColor: const Color.fromARGB(255, 159, 222, 238),
                      color: Colors.lightBlue,
                    ),

                    const SizedBox(height: 24),
                    _row('Price', goal.price),
                    _row('Saved', goal.saved),
                    _rowText('Priority', goal.priority ?? 'Low'),
                    _rowText(
                      'Description',
                      goal.description ?? 'No description',
                    ),
                    const Divider(height: 32),
                    _row('Remaining', goal.remaining, highlight: true),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: goal.remaining <= 0
                              ? Colors.grey
                              : Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: goal.remaining <= 0
                            ? null
                            : () => _showAddSavingsDialog(context),
                        child: const Text('Add Savings'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Priority banner
            Positioned(
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: getPriorityColor(goal.priority),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: Text(
                  (goal.priority ?? 'Low').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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

  Widget _rowText(String label, String text, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                color: highlight ? Colors.green : null,
              ),
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
                  description: goal.description,
                  priority: goal.priority,
                );

                await DBHelper.instance.updateGoal(updatedGoal);

                final goals = await DBHelper.instance.fetchGoals();
                final refreshedGoal = goals.firstWhere((g) => g.id == goal.id);
                setState(() {
                  goal = refreshedGoal;
                });

                Navigator.pop(context);
                Navigator.pop(context, refreshedGoal); // Return to homescreen
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
