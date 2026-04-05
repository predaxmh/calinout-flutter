import 'package:calinout/features/nutrient_logs/domain/entities/food.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:hive_ce/hive_ce.dart';

part 'food_hive.g.dart';

/// [FoodHive] is the Data Transfer Object (DTO) for local storage.

@HiveType(typeId: 1)
class FoodHive extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final int foodTypeId;

  @HiveField(4)
  final int? mealId;

  @HiveField(5)
  final double weightInGrams;

  @HiveField(6)
  final DateTime? consumedAt;

  @HiveField(7)
  final bool isTemplate;

  @HiveField(8)
  final double calories;

  @HiveField(9)
  final double protein;

  @HiveField(10)
  final double fat;

  @HiveField(11)
  final double carbs;

  @HiveField(12)
  final DateTime createdAt;

  @HiveField(13)
  final DateTime? updatedAt;

  FoodHive({
    required this.id,
    required this.userId,
    required this.name,
    required this.foodTypeId,
    this.mealId,
    required this.weightInGrams,
    this.consumedAt,
    this.isTemplate = false,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.createdAt,
    this.updatedAt,
  });

  Food toEntity() {
    return Food(
      id: id,
      name: name,
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
      consumedAt: consumedAt,
      createdAt: createdAt,
      foodTypeId: foodTypeId,
      userId: userId,
      weightInGrams: weightInGrams,
      isTemplate: isTemplate,
      mealId: mealId,
      updatedAt: updatedAt,
    );
  }

  /// Creates a Hive Model from a Domain Entity.
  /// Used when preparing data to be saved into the Hive box.
  factory FoodHive.fromEntity(Food entity) {
    return FoodHive(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      foodTypeId: entity.foodTypeId,
      weightInGrams: entity.weightInGrams,
      calories: entity.calories,
      protein: entity.protein,
      fat: entity.fat,
      carbs: entity.carbs,
      createdAt: entity.createdAt,
      isTemplate: entity.isTemplate,
    );
  }
}
