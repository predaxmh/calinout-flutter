import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_food_request.freezed.dart';
part 'update_food_request.g.dart';

@freezed
abstract class UpdateFoodRequest with _$UpdateFoodRequest {
  const factory UpdateFoodRequest({
    double? weightInGrams,
    DateTime? consumedAt,
    int? mealId,
  }) = _UpdateFoodRequest;

  factory UpdateFoodRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateFoodRequestFromJson(json);
}
