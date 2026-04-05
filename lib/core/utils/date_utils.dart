import 'package:calinout/features/home_manager/domain/entities/daily_log.dart';
import 'package:calinout/features/weight/presentation/controllers/weight_history_controller.dart';

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

List<WeightEntry> toWeightEntries(List<DailyLog> logs) {
  return logs
      .where((l) => l.weightAtLog != null && l.weightAtLog! > 0)
      .map(
        (l) => WeightEntry(
          date: l.date,
          weightKg: l.weightAtLog!,
          notes: l.dailyNotes,
          sourceLog: l,
        ),
      )
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));
}
