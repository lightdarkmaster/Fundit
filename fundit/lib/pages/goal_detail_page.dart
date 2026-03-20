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
  DateTime? estimatedDate;

  @override
  void initState() {
    super.initState();
    goal = widget.goal;
    estimatedDate = goal.estimatedDate;
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

  Map<String, double>? calculateSavingsPlan() {
    if (estimatedDate == null || goal.remaining <= 0) return null;

    final days = estimatedDate!
        .difference(DateTime.now())
        .inDays
        .clamp(1, 100000);

    return {
      'Daily': goal.remaining / days,
      'Weekly': goal.remaining / (days / 7),
      'Monthly': goal.remaining / (days / 30),
    };
  }

  Future<void> _pickEstimatedDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          estimatedDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (picked != null) {
      final updatedGoal = Goal(
        id: goal.id,
        name: goal.name,
        price: goal.price,
        saved: goal.saved,
        imagePath: goal.imagePath,
        description: goal.description,
        priority: goal.priority,
        estimatedDate: picked,
        createdAt: goal.createdAt,
      );

      await DBHelper.instance.updateGoal(updatedGoal);

      setState(() {
        goal = updatedGoal;
        estimatedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (goal.saved / goal.price).clamp(0.0, 1.0);
    final progressPercentage = (progress * 100).toStringAsFixed(0);
    final savingsPlan = calculateSavingsPlan();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${goal.name} Details',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===================== MAIN GOAL CARD =====================
            Stack(
              children: [
                Builder(
                  builder: (context) {
                    final isDarkMode =
                        Theme.of(context).brightness == Brightness.dark;
                    return Card(
                      color: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: isDarkMode
                            ? BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                                width: 1,
                              )
                            : BorderSide.none,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (goal.imagePath != null) ...[
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    barrierColor: Colors.black87,
                                    builder: (_) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      insetPadding: const EdgeInsets.all(16),
                                      child: GestureDetector(
                                        onTap: () => Navigator.pop(context),
                                        child: InteractiveViewer(
                                          minScale: 0.5,
                                          maxScale: 3.0,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: Image.file(
                                              File(goal.imagePath!),
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
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
                              const SizedBox(height: 16),
                            ],
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: Text(
                                  goal.name,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progress',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
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
                              backgroundColor: const Color.fromARGB(
                                255,
                                159,
                                222,
                                238,
                              ),
                              color: Colors.lightBlue,
                            ),
                            const SizedBox(height: 24),
                            _row('Goal', goal.price),
                            _row('Saved', goal.saved),
                            _rowText('Priority', goal.priority ?? 'Low'),
                            _rowText(
                              'Description',
                              goal.description ?? 'No description',
                            ),
                            const Divider(height: 32),
                            _row('Remaining', goal.remaining, highlight: true),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: goal.remaining <= 0
                                      ? Colors.grey
                                      : Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
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
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: goal.saved <= 0
                                    ? null
                                    : () => _showWithdrawSavingsDialog(context),
                                child: const Text('Withdraw Savings'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
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
            const SizedBox(height: 20),
            // ===================== SAVINGS PLAN CARD =====================
            Builder(
              builder: (context) {
                final isDarkMode =
                    Theme.of(context).brightness == Brightness.dark;
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: isDarkMode
                        ? BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1,
                          )
                        : BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Savings Plan',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              estimatedDate == null
                                  ? 'Estimated Date: Not set'
                                  : 'Target Date: ${DateFormat('MMM d, y').format(estimatedDate!)}',
                            ),
                            TextButton(
                              onPressed: _pickEstimatedDate,
                              child: const Text('Set Date'),
                            ),
                          ],
                        ),
                        if (savingsPlan != null) ...[
                          const Divider(height: 24),
                          ...savingsPlan.entries.map(
                            (e) => _row(e.key, e.value),
                          ),
                        ] else ...[
                          const SizedBox(height: 12),
                          const Text(
                            'Set a target date to see your savings breakdown.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
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

  Widget _rowText(String label, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Flexible(child: Text(text, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  void _showAddSavingsDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Savings'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
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
                  estimatedDate: goal.estimatedDate,
                  createdAt: goal.createdAt,
                );

                await DBHelper.instance.updateGoal(updatedGoal);

                // Refresh data from DB to ensure UI is accurate
                final refreshedGoal = (await DBHelper.instance.fetchGoals())
                    .firstWhere((g) => g.id == goal.id);

                setState(() => goal = refreshedGoal);
                if (mounted) {
                  Navigator.pop(
                    context,
                    true,
                  ); // true means "I changed something"
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawSavingsDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Withdraw Savings'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final withdrawAmount = double.tryParse(controller.text);

              if (withdrawAmount != null &&
                  withdrawAmount > 0 &&
                  withdrawAmount <= goal.saved) {
                final updatedGoal = Goal(
                  id: goal.id,
                  name: goal.name,
                  price: goal.price,
                  saved: goal.saved - withdrawAmount,
                  imagePath: goal.imagePath,
                  description: goal.description,
                  priority: goal.priority,
                  estimatedDate: goal.estimatedDate,
                  createdAt: goal.createdAt,
                );

                await DBHelper.instance.updateGoal(updatedGoal);

                final refreshedGoal = (await DBHelper.instance.fetchGoals())
                    .firstWhere((g) => g.id == goal.id);

                setState(() => goal = refreshedGoal);

                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }
}
