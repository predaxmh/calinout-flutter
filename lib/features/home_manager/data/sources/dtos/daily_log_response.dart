import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_log_response.freezed.dart';
part 'daily_log_response.g.dart';

@freezed
abstract class DailyLogResponse with _$DailyLogResponse {
  const factory DailyLogResponse({
    required int id,
    required String userId,
    required DateTime date,
    int? burnedCalories,
    double? weightAtLog,
    @Default(false) bool digestiveTrackCleared,
    @Default(false) bool isCheatDay,
    int? totalCalories,
    String? dailyNotes,
    int? targetCalorieOnThisDay,
    double? totalFoodWeight,
    double? totalFat,
    double? totalCarbs,
    double? totalProtein,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _DailyLogResponse;

  factory DailyLogResponse.fromJson(Map<String, dynamic> json) =>
      _$DailyLogResponseFromJson(json);
}
