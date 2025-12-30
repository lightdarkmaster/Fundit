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

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  List<Goal> goals = [];
  int touchedIndex = -1;
  Offset? tapPosition;
  static final NumberFormat pesoFormatter = NumberFormat('#,##0.00', 'en_PH');
  late Goal? topSavedGoal = goals.isEmpty
      ? null
      : goals.reduce((a, b) => a.saved > b.saved ? a : b);

  double totalSaved = 0;
  double totalPrice = 0;
  double totalRemaining = 0;
  double totalCompleted = 0;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadGoals();
    _tabController = TabController(length: 2, vsync: this); // <-- 2 tabs now
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'), // <-- Your current dashboard
            Tab(text: 'Analytics'), // <-- New tab for additional analytics
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Your current dashboard body
          Padding(
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
                              cardColor: const Color.fromARGB(
                                255,
                                232,
                                245,
                                233,
                              ),
                              titleColor: Colors.green.shade800,
                              valueColor: Colors.green.shade900,
                            ),
                            const SizedBox(width: 12),
                            _summaryCard(
                              title: 'Total Remaining',
                              amount: totalRemaining,
                              cardColor: const Color.fromARGB(
                                255,
                                255,
                                235,
                                238,
                              ),
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
                              cardColor: const Color.fromARGB(
                                255,
                                227,
                                242,
                                253,
                              ),
                              titleColor: Colors.blue.shade800,
                              valueColor: Colors.blue.shade900,
                              isInteger: true,
                            ),
                            const SizedBox(width: 12),
                            _summaryCard(
                              title: 'Overall Progress',
                              amount: overallProgress * 100,
                              cardColor: const Color.fromARGB(
                                255,
                                255,
                                243,
                                224,
                              ),
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
                              cardColor: const Color.fromARGB(
                                255,
                                227,
                                242,
                                253,
                              ),
                              titleColor: Colors.purple.shade800,
                              valueColor: Colors.purple.shade900,
                              isInteger: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Progress Bars per Goal
                        const Center(
                          child: Text(
                            'Progress By Goal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...goals.map((goal) {
                          double progress = (goal.saved / goal.price).clamp(
                            0.0,
                            1.0,
                          );
                          Color baseColor = Colors
                              .primaries[goal.id! % Colors.primaries.length];
                          Color vibrantColor = baseColor;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        goal.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${(progress * 100).toStringAsFixed(0)}%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
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
                        const Center(
                          child: Text(
                            'Analytics Overview',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Pie Chart
                        SizedBox(
                          height: 350,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Theme.of(context).dividerColor,
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Stack(
                                  children: [
                                    GestureDetector(
                                      onTapDown: (details) {
                                        setState(() {
                                          tapPosition = details.localPosition;
                                        });
                                      },
                                      child: PieChart(
                                        PieChartData(
                                          centerSpaceRadius: 55,
                                          sectionsSpace: 4,
                                          pieTouchData: PieTouchData(
                                            touchCallback: (event, response) {
                                              setState(() {
                                                if (!event
                                                        .isInterestedForInteractions ||
                                                    response == null ||
                                                    response.touchedSection ==
                                                        null) {
                                                  touchedIndex = -1;
                                                  return;
                                                }
                                                touchedIndex = response
                                                    .touchedSection!
                                                    .touchedSectionIndex;
                                              });
                                            },
                                          ),
                                          sections: goals.asMap().entries.map((
                                            entry,
                                          ) {
                                            final index = entry.key;
                                            final goal = entry.value;

                                            final progress = goal.price == 0
                                                ? 0
                                                : (goal.saved / goal.price)
                                                      .clamp(0.0, 1.0);

                                            final color =
                                                Colors.primaries[goal.id! %
                                                    Colors.primaries.length];

                                            return PieChartSectionData(
                                              value: goal.saved,
                                              color: color.withValues(
                                                alpha: 0.85,
                                              ),
                                              radius: index == touchedIndex
                                                  ? 80
                                                  : 70,
                                              title:
                                                  '${(progress * 100).toStringAsFixed(0)}%',
                                              titleStyle: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),

                                    // Center text
                                    Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Savings',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleSmall,
                                          ),
                                          Text(
                                            'Overview',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Tooltip
                              if (touchedIndex != -1 && tapPosition != null)
                                Positioned(
                                  left: tapPosition!.dx - 60,
                                  top: tapPosition!.dy - 70,
                                  child: _touchTooltip(
                                    context,
                                    goals[touchedIndex],
                                  ),
                                ),
                            ],
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
                                Container(
                                  width: 12,
                                  height: 12,
                                  color: baseColor,
                                ),
                                const SizedBox(width: 4),
                                Text(goal.name),
                              ],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // Bar Chart: Saved Amount per Goal
                        const Center(
                          child: Text(
                            'Saved Amount per Goal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Theme.of(context).dividerColor,
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              height: 350,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: goals.isNotEmpty
                                      ? goals
                                                .map((g) => g.price)
                                                .reduce(
                                                  (a, b) => a > b ? a : b,
                                                ) *
                                            1.1
                                      : 1, // Add 10% padding at top
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: goals.isNotEmpty
                                        ? goals
                                                  .map((g) => g.price)
                                                  .reduce(
                                                    (a, b) => a > b ? a : b,
                                                  ) /
                                              4
                                        : 1,
                                  ),
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      tooltipBorderRadius:
                                          BorderRadius.circular(8),
                                      tooltipPadding: const EdgeInsets.all(12),
                                      getTooltipItem:
                                          (group, groupIndex, rod, rodIndex) {
                                            final goal = goals[group.x.toInt()];
                                            return BarTooltipItem(
                                              '${goal.name}\n',
                                              const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text:
                                                      'Saved: ₱${pesoFormatter.format(goal.saved)}',
                                                  style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                    ),
                                  ),
                                  barGroups: goals.asMap().entries.map((entry) {
                                    final goal = entry.value;
                                    final color =
                                        Colors.primaries[goal.id! %
                                            Colors.primaries.length];
                                    return BarChartGroupData(
                                      x: entry.key,
                                      barRods: [
                                        BarChartRodData(
                                          toY: goal.saved,
                                          color: color,
                                          width: 18,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 42,
                                        getTitlesWidget: (value, meta) {
                                          int index = value.toInt();
                                          if (index < 0 ||
                                              index >= goals.length) {
                                            return const SizedBox.shrink();
                                          }

                                          // Show every 2nd label if too many goals
                                          if (goals.length > 8 &&
                                              index % 2 != 0) {
                                            return const SizedBox.shrink();
                                          }

                                          return SideTitleWidget(
                                            meta: meta,
                                            space: 6,
                                            child: Text(
                                              goals[index].name,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: false,
                                        reservedSize: 50,
                                        interval: goals.isNotEmpty
                                            ? goals
                                                      .map((g) => g.price)
                                                      .reduce(
                                                        (a, b) => a > b ? a : b,
                                                      ) /
                                                  4
                                            : 1,
                                        getTitlesWidget: (value, meta) {
                                          return SideTitleWidget(
                                            meta: meta,
                                            space: 6,
                                            child: Text(
                                              pesoFormatter.format(value),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Line Chart: Trend of Total Saved
                        const Center(
                          child: Text(
                            'Savings Trend',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white70
                                  : Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              height: 350,
                              child: LineChart(
                                LineChartData(
                                  minY: 0,
                                  maxY: goals.isNotEmpty
                                      ? goals
                                                .map((g) => g.saved)
                                                .reduce(
                                                  (a, b) => a > b ? a : b,
                                                ) *
                                            1.1
                                      : 1,
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: true,
                                    horizontalInterval: goals.isNotEmpty
                                        ? goals
                                                  .map((g) => g.saved)
                                                  .reduce(
                                                    (a, b) => a > b ? a : b,
                                                  ) /
                                              4
                                        : 1,
                                  ),
                                  borderData: FlBorderData(show: false),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: goals.asMap().entries.map((entry) {
                                        return FlSpot(
                                          entry.key.toDouble(),
                                          entry.value.saved,
                                        );
                                      }).toList(),
                                      isCurved: true,
                                      barWidth: 3,
                                      color: Colors.lightBlueAccent,
                                      dotData: FlDotData(show: true),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: Colors.lightBlue.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                  ],

                                  // Add this for tooltip formatting
                                  lineTouchData: LineTouchData(
                                    touchTooltipData: LineTouchTooltipData(
                                      getTooltipItems: (touchedSpots) {
                                        return touchedSpots.map((touchedSpot) {
                                          final index = touchedSpot.x.toInt();
                                          if (index < 0 ||
                                              index >= goals.length) {
                                            return null;
                                          }

                                          final value = goals[index].saved;
                                          return LineTooltipItem(
                                            '₱${pesoFormatter.format(value)}',
                                            const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          );
                                        }).toList();
                                      },
                                    ),
                                  ),

                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 42,
                                        getTitlesWidget: (value, meta) {
                                          int index = value.toInt();
                                          if (index < 0 ||
                                              index >= goals.length) {
                                            return const SizedBox.shrink();
                                          }
                                          if (goals.length > 10 &&
                                              index % 2 != 0) {
                                            return const SizedBox.shrink();
                                          }
                                          return SideTitleWidget(
                                            meta: meta,
                                            space: 6,
                                            child: Transform.rotate(
                                              angle: -0.5,
                                              child: Text(
                                                goals[index].name,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 50,
                                        interval: goals.isNotEmpty
                                            ? goals
                                                      .map((g) => g.saved)
                                                      .reduce(
                                                        (a, b) => a > b ? a : b,
                                                      ) /
                                                  4
                                            : 1,
                                        getTitlesWidget: (value, meta) {
                                          return SideTitleWidget(
                                            meta: meta,
                                            space: 6,
                                            child: Text(
                                              pesoFormatter.format(value),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
          // Tab 2: Analytics
          _analyticsTab(context, goals, this, topSavedGoal),
        ],
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

Widget _summaryCardStandalone({
  required BuildContext context,
  required String title,
  required double amount,
  String? subtitle,
  required Color cardColor,
  required Color titleColor,
  required Color valueColor,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final pesoFormatter = NumberFormat('#,##0.00', 'en_PH');

  return SizedBox(
    width: (MediaQuery.of(context).size.width - 48) / 2,
    height: 110,
    child: Card(
      color: isDark ? cardColor.withValues(alpha: 0.18) : cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 14, color: titleColor)),
            const Spacer(),
            Text(
              '₱${pesoFormatter.format(amount)}',
              style: TextStyle(
                fontSize: 16,
                color: valueColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: valueColor),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

Widget _touchTooltip(BuildContext context, Goal goal) {
  final progress = goal.price == 0 ? 0 : (goal.saved / goal.price) * 100;
  var pesoFormatter = NumberFormat('#,##0.00', 'en_PH');
  return Material(
    elevation: 5,
    borderRadius: BorderRadius.circular(8),
    color: Theme.of(context).colorScheme.surface,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            goal.name,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '₱${pesoFormatter.format(goal.saved)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            '${progress.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}

Goal? getTopSavedGoal(List<Goal> goals) {
  if (goals.isEmpty) return null;

  return goals.reduce((a, b) => a.saved >= b.saved ? a : b);
}

Widget _analyticsTab(
  BuildContext context,
  List<Goal> goals,
  _DashboardPageState state,
  Goal? topSavedGoal,
) {
  final pesoFormatter = NumberFormat('#,##0.00', 'en_PH');
  final topGoal = getTopSavedGoal(goals);

  _summaryCardStandalone(
    context: context,
    title: 'Top Saved Goal',
    amount: topGoal?.saved ?? 0,
    subtitle: topGoal?.name ?? 'No data',
    cardColor: Colors.green.shade100,
    titleColor: Colors.green.shade800,
    valueColor: Colors.green.shade900,
  );

  double totalSaved = goals.fold(0, (sum, g) => sum + g.saved);
  double totalPrice = goals.fold(0, (sum, g) => sum + g.price);

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Summary / KPIs',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _summaryCardStandalone(
              context: context,
              title: 'Average Saved',
              subtitle: 'Per Goal',
              amount: totalSaved / goals.length.toDouble(),
              cardColor: Colors.cyan.shade100,
              titleColor: Colors.cyan.shade800,
              valueColor: Colors.cyan.shade900,
            ),
            const SizedBox(width: 12),
            _summaryCardStandalone(
              context: context,
              title: 'Top Saving Goal',
              amount: topGoal?.saved ?? 0,
              subtitle: topGoal?.name ?? 'No data',
              cardColor: Colors.amber.shade100,
              titleColor: Colors.amber.shade800,
              valueColor: Colors.amber.shade900,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'Progress / Radial Charts',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160, // height to accommodate cards
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: goals.map((goal) {
                double progress = (goal.saved / goal.price).clamp(0.0, 1.0);
                Color baseColor =
                    Colors.primaries[goal.id! % Colors.primaries.length];

                // Adjust width dynamically
                double cardWidth = MediaQuery.of(context).size.width / 2.5;
                if (MediaQuery.of(context).size.width > 600) {
                  cardWidth = MediaQuery.of(context).size.width / 4;
                }

                // Border color based on theme
                Color borderColor =
                    Theme.of(context).brightness == Brightness.dark
                    ? Colors.white24
                    : Colors.grey.shade300;

                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: cardWidth,
                    height: 140,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CustomPaint(
                        foregroundPainter: ProgressBorderPainter(
                          progress: progress,
                          color: baseColor,
                          strokeWidth: 4,
                          radius: 16,
                        ),
                        child: Card(
                          elevation: 3,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: borderColor, width: 1.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${(progress * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: baseColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  goal.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '₱${NumberFormat('#,##0.00', 'en_PH').format(goal.saved)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'of ₱${NumberFormat('#,##0.00', 'en_PH').format(goal.price)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 24),

        Center(
          child: Text(
            'Goals Table',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            dataRowMinHeight: 40,
            dataRowMaxHeight: 80,
            columnSpacing: 24,
            border: TableBorder.all(color: Colors.grey.shade300, width: 1),
            columns: const [
              DataColumn(label: Text('Goal')),
              DataColumn(label: Text('Saved')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Remaining')),
              DataColumn(label: Text('Progress')),
            ],
            rows: goals.map((goal) {
              double progress = (goal.saved / goal.price).clamp(0.0, 1.0) * 100;
              Color progressColor = progress == 100
                  ? Colors.green
                  : Colors.orange; // Highlight completed goals

              return DataRow(
                color: WidgetStateProperty.resolveWith<Color?>((
                  Set<WidgetState> states,
                ) {
                  if (states.contains(WidgetState.hovered)) {
                    return Colors.grey.shade100; // Hover color
                  }
                  return null; // Default row color
                }),
                cells: [
                  DataCell(Text(goal.name)),
                  DataCell(Text('₱${pesoFormatter.format(goal.saved)}')),
                  DataCell(Text('₱${pesoFormatter.format(goal.price)}')),
                  DataCell(Text('₱${pesoFormatter.format(goal.remaining)}')),
                  DataCell(
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress / 100,
                              color: progressColor,
                              backgroundColor: progressColor.withValues(
                                alpha: 0.2,
                              ),
                              minHeight: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${progress.toStringAsFixed(0)}%'),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 24),

        Center(
          child: const Text(
            'Stacked Chart: Saved vs Remaining',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: goals.isNotEmpty
                  ? goals.map((g) => g.price).reduce((a, b) => a > b ? a : b)
                  : 1,
              barGroups: goals.asMap().entries.map((entry) {
                final goal = entry.value;
                final colorSaved = Colors.green;
                final colorRemaining = Colors.red;
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: goal.saved,
                      color: colorSaved,
                      width: 18,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    BarChartRodData(
                      toY: goal.remaining,
                      color: colorRemaining,
                      width: 18,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(show: true),
              gridData: FlGridData(show: true),
            ),
          ),
        ),

        const SizedBox(height: 24),

        Center(
          child: const Text(
            'Heatmap: Goal Completion',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: goals.map((goal) {
              double progress = (goal.saved / goal.price).clamp(0.0, 1.0);
              Color color = Color.lerp(Colors.red, Colors.green, progress)!;
              return Container(
                width: 30,
                height: 30,
                color: color,
                alignment: Alignment.center,
                child: Text(
                  goal.name.substring(0, 1),
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 24),
        Center(
          child: Text(
            'Overall Savings Gauge',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: RadarChart(
            RadarChartData(
              dataSets: [
                RadarDataSet(
                  dataEntries: goals.map((goal) {
                    // Each entry is the percentage of saved amount
                    return RadarEntry(
                      value: goal.price == 0
                          ? 0
                          : (goal.saved / goal.price) * 100,
                    );
                  }).toList(),
                  borderColor: Colors.blue,
                  fillColor: Colors.blue.withOpacity(0.3),
                  entryRadius: 3,
                  borderWidth: 2,
                ),
              ],
              radarBackgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              radarBorderData: BorderSide(color: Colors.grey.shade300),
              titlePositionPercentageOffset: 0.2,
              tickCount: 5,
              ticksTextStyle: const TextStyle(color: Colors.grey, fontSize: 10),
              tickBorderData: BorderSide(color: Colors.grey.shade300),
              gridBorderData: BorderSide(color: Colors.grey.shade300),
              getTitle: (index, angle) {
                // Show goal names around the radar
                if (index < 0 || index >= goals.length) {
                  return RadarChartTitle(text: '');
                }
                return RadarChartTitle(text: goals[index].name);
              },
            ),
            duration: const Duration(milliseconds: 400),
          ),
        ),
      ],
    ),
  );
}

class ProgressBorderPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final double radius;

  ProgressBorderPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 4,
    this.radius = 16,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final path = Path()..addRRect(rrect);

    final metrics = path.computeMetrics().first;
    final extractLength = metrics.length * progress;

    final extractPath = metrics.extractPath(0, extractLength);
    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(covariant ProgressBorderPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
