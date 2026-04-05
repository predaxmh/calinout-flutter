import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_daily_log_request.freezed.dart';
part 'create_daily_log_request.g.dart';

@freezed
abstract class CreateDailyLogRequest with _$CreateDailyLogRequest {
  const factory CreateDailyLogRequest({
    required DateTime date,
    int? burnedCalories,
    double? weightAtLog,
    @Default(false) bool digestiveTrackCleared,
    @Default(false) bool isCheatDay,
    int? targetCalorieOnThisDay,
    String? dailyNotes,
    int? totalCalories,
    double? totalFoodWeight,
    double? totalFat,
    double? totalCarbs,
    double? totalProtein,
  }) = _CreateDailyLogRequest;

  factory CreateDailyLogRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateDailyLogRequestFromJson(json);
}
