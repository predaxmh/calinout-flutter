import 'package:calinout/features/nutrient_logs/data/sources/dtos/food_dtos/food_response.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal_response.freezed.dart';
part 'meal_response.g.dart';

@freezed
abstract class MealResponse with _$MealResponse {
  const factory MealResponse({
    required int id,
    required String userId,
    required String name,
    required bool isTemplate,
    DateTime? consumedAt,
    required double totalCalories,
    required double totalCarbs,
    required double totalProtein,
    required double totalFat,
    required double totalWeight,
    required List<FoodResponse> foods,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _MealResponse;

  factory MealResponse.fromJson(Map<String, dynamic> json) =>
      _$MealResponseFromJson(json);
}
