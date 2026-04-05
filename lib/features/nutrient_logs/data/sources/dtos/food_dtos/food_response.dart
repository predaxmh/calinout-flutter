import 'package:freezed_annotation/freezed_annotation.dart';

part 'food_response.freezed.dart';
part 'food_response.g.dart';

@freezed
abstract class FoodResponse with _$FoodResponse {
  const factory FoodResponse({
    required int id,
    required String userId,
    required int foodTypeId,
    required String name,
    int? mealId,
    required double weightInGrams,
    DateTime? consumedAt,
    required bool isTemplate,
    required double calories,
    required double protein,
    required double fat,
    required double carbs,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _FoodResponse;

  factory FoodResponse.fromJson(Map<String, dynamic> json) =>
      _$FoodResponseFromJson(json);
}
