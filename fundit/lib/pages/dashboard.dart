import 'package:flutter/material.dart';
import 'package:fundit/pages/db_helper.dart';
import 'package:fundit/pages/goal_model.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    double overallProgress = totalPrice == 0 ? 0 : (totalSaved / totalPrice);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), centerTitle: true),
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
                    // Summary Cards
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _summaryCard(
                          title: 'Total Savings',
                          amount: totalSaved,
                          color: const Color.fromARGB(255, 0, 119, 50),
                        ),
                        _summaryCard(
                          title: 'Total Remaining',
                          amount: totalRemaining,
                          color: const Color.fromARGB(255, 123, 0, 0),
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
                          color: const Color.fromARGB(255, 0, 41, 154),
                          isInteger: true,
                        ),
                        _summaryCard(
                          title: 'Overall Progress',
                          amount: overallProgress * 100,
                          color: const Color.fromARGB(255, 136, 59, 0),
                          isPercentage: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Progress Bars per Goal
                    const Text(
                      'Progress by Goal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: vibrantColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${(progress * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: vibrantColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: progress,
                              minHeight: 10,
                              color: vibrantColor,
                              backgroundColor: vibrantColor.withOpacity(0.2),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

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
                                  if (index < 0 || index >= goals.length)
                                    return const SizedBox.shrink();
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
                                  if (index < 0 || index >= goals.length)
                                    return const SizedBox.shrink();
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
    required Color color,
    bool isPercentage = false,
    bool isInteger = false,
  }) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isPercentage
                    ? '${amount.toStringAsFixed(0)}%'
                    : isInteger
                    ? amount.toInt().toString()
                    : '₱${pesoFormatter.format(amount)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
