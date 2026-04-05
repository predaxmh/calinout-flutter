import 'package:calinout/features/nutrient_logs/data/sources/dtos/food_dtos/food_mapper_extention.dart';
import 'package:calinout/features/nutrient_logs/data/sources/dtos/meal_dtos/meal_response.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/meal.dart';

extension MealMapper on MealResponse {
  Meal toEntity() {
    return Meal(
      id: id,
      userId: userId,
      name: name,
      isTemplate: isTemplate,
      consumedAt: consumedAt,
      totalCalories: totalCalories,
      totalCarbs: totalCarbs,
      totalProtein: totalProtein,
      totalFat: totalFat,
      totalWeight: totalWeight,
      createdAt: createdAt,
      updatedAt: updatedAt,
      foods: foods.map((foodRes) => foodRes.toEntity()).toList(),
    );
  }
}
