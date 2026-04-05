import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_food_request.freezed.dart';
part 'create_food_request.g.dart';

@freezed
abstract class CreateFoodRequest with _$CreateFoodRequest {
  const factory CreateFoodRequest({
    required int foodTypeId,
    int? mealId,
    required double weightInGrams,
    @Default(false) bool isTemplate,
    DateTime? consumedAt,
  }) = _CreateFoodRequest;

  factory CreateFoodRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateFoodRequestFromJson(json);
}
