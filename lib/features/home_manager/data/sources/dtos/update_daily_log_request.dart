import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_daily_log_request.freezed.dart';
part 'update_daily_log_request.g.dart';

@freezed
abstract class UpdateDailyLogRequest with _$UpdateDailyLogRequest {
  const factory UpdateDailyLogRequest({
    int? burnedCalories,
    double? weightAtLog,
    bool? digestiveTrackCleared,
    bool? isCheatDay,
    int? targetCalorieOnThisDay,
    String? dailyNotes,
  }) = _UpdateDailyLogRequest;

  factory UpdateDailyLogRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateDailyLogRequestFromJson(json);
}
