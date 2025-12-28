import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fundit/pages/db_helper.dart';
import 'package:fundit/pages/goal_model.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> historyRecords = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final goals = await DBHelper.instance.fetchGoals();

    // Flatten all creation and update records
    List<Map<String, dynamic>> records = [];

    for (var goal in goals) {
      if (goal.createdAt != null) {
        records.add({
          'goalName': goal.name,
          'action': 'Created',
          'timestamp': goal.createdAt!,
        });
      }
      // if (goal.updatedAt != null) {
      //   records.add({
      //     'goalName': goal.name,
      //     'action': 'Edited',
      //     'timestamp': goal.updatedAt!,
      //   });
      // }
    }

    // Sort by timestamp descending
    records.sort(
      (a, b) =>
          (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime),
    );

    setState(() {
      historyRecords = records;
    });
  }

  String formatTimestamp(DateTime dt) {
    return DateFormat('MMMM d, y (EEEE, hh:mma)').format(dt).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: historyRecords.isEmpty
          ? const Center(child: Text('No history yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historyRecords.length,
              itemBuilder: (_, index) {
                final record = historyRecords[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${record['goalName']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${record['action']} • ${formatTimestamp(record['timestamp'])}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
