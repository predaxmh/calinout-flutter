import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_meal_request.freezed.dart';
part 'update_meal_request.g.dart';

@freezed
abstract class UpdateMealRequest with _$UpdateMealRequest {
  const factory UpdateMealRequest({
    String? name,
    DateTime? consumedAt,
    bool? isTemplate,
    List<int>? foodIds,
  }) = _UpdateMealRequest;

  factory UpdateMealRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateMealRequestFromJson(json);
}
