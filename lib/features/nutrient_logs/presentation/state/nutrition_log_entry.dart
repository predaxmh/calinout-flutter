import 'package:calinout/features/nutrient_logs/domain/entities/food.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/meal.dart';

sealed class NutritionLogEntry {
  DateTime get sortDate => DateTime.now();
}

class FoodEntry extends NutritionLogEntry {
  final Food food;
  FoodEntry(this.food);

  @override
  DateTime get sortDate => food.consumedAt ?? food.createdAt;
}

class MealEntry extends NutritionLogEntry {
  final Meal meal;
  MealEntry(this.meal);

  @override
  DateTime get sortDate => meal.consumedAt ?? meal.createdAt;
}

class TitleEntry extends NutritionLogEntry {
  final String title;
  TitleEntry(this.title);
}
