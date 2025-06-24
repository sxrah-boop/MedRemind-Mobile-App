import 'package:hopeless/models/history_model.dart';
import 'package:hopeless/models/prescription_model.dart';

Map<String, int> calculateTodayStats({
  required List<Prescription> prescriptions,
  required List<HistoryEntry> history,
}) {
  final today = DateTime.now();
  final todayKey = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][today.weekday - 1];

  int totalDoses = 0;
  int takenDoses = 0;

  for (var p in prescriptions) {
    final isToday = p.frequencyPerWeek.contains(todayKey) || p.frequencyPerWeek.length == 7;

    if (isToday) {
      for (var s in p.schedules) {
        totalDoses++;

        final isTaken = history.any((entry) {
          final entryDate = DateTime.tryParse(entry.confirmedAt);
          return entry.horaireId == s.id &&
              entry.status == 'taken' &&
              entryDate != null &&
              entryDate.year == today.year &&
              entryDate.month == today.month &&
              entryDate.day == today.day;
        });

        if (isTaken) takenDoses++;
      }
    }
  }

  return {
    'total': totalDoses,
    'taken': takenDoses,
  };
}