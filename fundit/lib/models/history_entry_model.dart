class HistoryEntry {
  final String goalName;
  final String action; // "Created" or "Edited"
  final DateTime timestamp;

  HistoryEntry({
    required this.goalName,
    required this.action,
    required this.timestamp,
  });
}
