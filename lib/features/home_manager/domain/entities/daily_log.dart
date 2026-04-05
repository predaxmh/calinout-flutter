import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_log.freezed.dart';

@freezed
abstract class DailyLog with _$DailyLog {
  const factory DailyLog({
    required int id,
    required String userId,
    required DateTime date,
    required int burnedCalories,
    required double? weightAtLog,
    required bool digestiveTrackCleared,
    required bool isCheatDay,
    required int totalCalories,
    required String dailyNotes,
    required int targetCalorieOnThisDay,
    required double totalFoodWeight,
    required double totalFat,
    required double totalCarbs,
    required double totalProtein,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _DailyLog;
}
