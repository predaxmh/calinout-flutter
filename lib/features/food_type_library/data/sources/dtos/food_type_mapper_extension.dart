import 'package:calinout/features/food_type_library/data/sources/dtos/food_type_response.dart';
import 'package:calinout/features/food_type_library/domain/entities/food_type.dart';

extension FoodTypeMapper on FoodTypeResponse {
  FoodType toEntity() {
    return FoodType(
      id: id,
      name: name,
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
      baseWeightInGrams: baseWeightInGrams,
      createdAt: createdAt,
    );
  }
}
