import 'package:calinout/features/home_manager/data/sources/dtos/daily_log_response.dart';
import 'package:calinout/features/home_manager/domain/entities/daily_log.dart';

extension DailyLogMapper on DailyLogResponse {
  DailyLog toEntity() {
    return DailyLog(
      id: id,
      userId: userId,
      date: date,
      burnedCalories: burnedCalories ?? 0,
      weightAtLog: weightAtLog ?? 0,
      digestiveTrackCleared: digestiveTrackCleared,
      isCheatDay: isCheatDay,
      totalCalories: totalCalories ?? 0,
      dailyNotes: dailyNotes ?? "",
      targetCalorieOnThisDay: targetCalorieOnThisDay ?? 0,
      totalFoodWeight: totalFoodWeight ?? 0,
      totalFat: totalFat ?? 0,
      totalCarbs: totalCarbs ?? 0,
      totalProtein: totalProtein ?? 0,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
