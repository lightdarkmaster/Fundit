import 'package:flutter/material.dart';
import 'package:fundit/db/db_helper.dart';
import 'package:fundit/models/goal_model.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:fundit/db/db_helper.dart';
import 'package:fundit/models/goal_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Goal> goals = [];
  static final NumberFormat pesoFormatter = NumberFormat('#,##0.00', 'en_PH');

  double totalSaved = 0;
  double totalPrice = 0;
  double totalRemaining = 0;
  double totalCompleted = 0;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    goals = await DBHelper.instance.fetchGoals();
    _calculateTotals();
    setState(() {});
  }

  void _calculateTotals() {
    totalSaved = goals.fold(0, (sum, goal) => sum + goal.saved);
    totalPrice = goals.fold(0, (sum, goal) => sum + goal.price);
    totalRemaining = goals.fold(0, (sum, goal) => sum + goal.remaining);
    totalCompleted = goals
        .where((goal) => goal.saved >= goal.price)
        .length
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    double overallProgress = totalPrice == 0 ? 0 : (totalSaved / totalPrice);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: goals.isEmpty
            ? const Center(
                child: Text(
                  'No goals yet.\nAdd some goals to see the dashboard.',
                  textAlign: TextAlign.center,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _summaryCard(
                          title: 'Total Savings',
                          amount: totalSaved,
                          cardColor: const Color.fromARGB(255, 232, 245, 233),
                          titleColor: Colors.green.shade800,
                          valueColor: Colors.green.shade900,
                        ),
                        const SizedBox(width: 12),
                        _summaryCard(
                          title: 'Total Remaining',
                          amount: totalRemaining,
                          cardColor: const Color.fromARGB(255, 255, 235, 238),
                          titleColor: Colors.red.shade800,
                          valueColor: Colors.red.shade900,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _summaryCard(
                          title: 'Number of Goals',
                          amount: goals.length.toDouble(),
                          cardColor: const Color.fromARGB(255, 227, 242, 253),
                          titleColor: Colors.blue.shade800,
                          valueColor: Colors.blue.shade900,
                          isInteger: true,
                        ),
                        const SizedBox(width: 12),
                        _summaryCard(
                          title: 'Overall Progress',
                          amount: overallProgress * 100,
                          cardColor: const Color.fromARGB(255, 255, 243, 224),
                          titleColor: Colors.orange.shade800,
                          valueColor: Colors.orange.shade900,
                          isPercentage: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _summaryCard(
                          title: 'Goals Completed',
                          amount: totalCompleted,
                          cardColor: const Color.fromARGB(255, 227, 242, 253),
                          titleColor: Colors.purple.shade800,
                          valueColor: Colors.purple.shade900,
                          isInteger: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Progress Bars per Goal
                    Text(
                      'Progress by Goal',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...goals.map((goal) {
                      double progress = (goal.saved / goal.price).clamp(
                        0.0,
                        1.0,
                      );
                      Color baseColor =
                          Colors.primaries[goal.id! % Colors.primaries.length];
                      Color vibrantColor = baseColor;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    goal.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${(progress * 100).toStringAsFixed(0)}%',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: progress,
                              minHeight: 10,
                              color: vibrantColor,
                              borderRadius: BorderRadius.circular(5),
                              backgroundColor: const Color.fromARGB(
                                255,
                                218,
                                204,
                                204,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Analytics Section
                    const Text(
                      'Analytics Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Pie Chart
                    SizedBox(
                      height: 220,
                      child: PieChart(
                        PieChartData(
                          sections: goals.map((goal) {
                            Color baseColor = Colors
                                .primaries[goal.id! % Colors.primaries.length];
                            Color vibrantColor = baseColor;
                            return PieChartSectionData(
                              value: goal.saved,
                              color: vibrantColor,
                              title:
                                  '${(goal.saved / goal.price * 100).toStringAsFixed(0)}%',
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Pie Chart Legends
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: goals.map((goal) {
                        Color baseColor = Colors
                            .primaries[goal.id! % Colors.primaries.length];
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 12, height: 12, color: baseColor),
                            const SizedBox(width: 4),
                            Text(goal.name),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Bar Chart: Saved Amount per Goal
                    const Text(
                      'Saved Amount per Goal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: goals
                              .map((g) => g.price)
                              .reduce((a, b) => a > b ? a : b),
                          barGroups: goals.asMap().entries.map((entry) {
                            final goal = entry.value;
                            Color baseColor = Colors
                                .primaries[goal.id! % Colors.primaries.length];
                            Color vibrantColor = baseColor;
                            return BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: goal.saved,
                                  color: vibrantColor,
                                  width: 20,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            );
                          }).toList(),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  int index = value.toInt();
                                  if (index < 0 || index >= goals.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return SideTitleWidget(
                                    meta: meta,
                                    space: 4,
                                    child: Text(
                                      goals[index].name,
                                      style: const TextStyle(fontSize: 10),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                },
                                reservedSize: 40,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Line Chart: Trend of Total Saved
                    const Text(
                      'Savings Trend',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: goals
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => FlSpot(
                                      entry.key.toDouble(),
                                      entry.value.saved,
                                    ),
                                  )
                                  .toList(),
                              isCurved: true,
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.lightBlue.withOpacity(0.3),
                              ),
                              color: Colors.lightBlueAccent,
                            ),
                          ],
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  int index = value.toInt();
                                  if (index < 0 || index >= goals.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return SideTitleWidget(
                                    meta: meta,
                                    space: 4,
                                    child: Text(
                                      goals[index].name,
                                      style: const TextStyle(fontSize: 10),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                },
                                reservedSize: 40,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                          ),
                          borderData: FlBorderData(show: true),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required double amount,
    required Color cardColor,
    Color titleColor = Colors.white,
    Color valueColor = Colors.white,
    bool isInteger = false,
    bool isPercentage = false,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Card(
        // Retain custom card color in light mode, use theme surface in dark mode
        color: isDark ? Theme.of(context).colorScheme.surface : cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark
                ? Colors.white
                : Colors.transparent, // White border in dark mode
            width: 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: titleColor, // Always use the passed color
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isPercentage
                    ? '${amount.toStringAsFixed(0)}%'
                    : isInteger
                    ? amount.toInt().toString()
                    : '₱ ${pesoFormatter.format(amount)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: valueColor, // Always use the passed color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
