import 'package:calinout/features/nutrient_logs/data/sources/dtos/food_dtos/create_food_request.dart';
import 'package:calinout/features/nutrient_logs/data/sources/dtos/food_dtos/food_response.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/food.dart';

extension FoodMapper on FoodResponse {
  Food toEntity() {
    return Food(
      id: id,
      userId: userId,
      foodTypeId: foodTypeId,
      name: name,
      mealId: mealId,
      weightInGrams: weightInGrams,
      consumedAt: consumedAt,
      isTemplate: isTemplate,
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension FoodRequestMapper on Food {
  CreateFoodRequest toCreateFoodRequest() {
    return CreateFoodRequest(
      foodTypeId: foodTypeId,
      mealId: mealId,
      weightInGrams: weightInGrams,
      consumedAt: consumedAt,
      isTemplate: isTemplate,
    );
  }
}
