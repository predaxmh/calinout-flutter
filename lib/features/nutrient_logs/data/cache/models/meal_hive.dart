import 'package:calinout/features/nutrient_logs/domain/entities/meal.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hive_ce/hive_ce.dart';

part 'meal_hive.g.dart';

/// [MealHive] is the Data Transfer Object (DTO) for local storage .

@HiveType(typeId: 2)
class MealHive extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final bool isTemplate;

  @HiveField(4)
  final DateTime? consumedAt;

  @HiveField(5)
  final double totalCalories;

  @HiveField(6)
  final double totalCarbs;

  @HiveField(7)
  final double totalProtein;

  @HiveField(8)
  final double totalFat;

  @HiveField(9)
  final double totalWeight;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime? updatedAt;

  MealHive({
    required this.id,
    required this.userId,
    required this.name,
    this.isTemplate = false,
    this.consumedAt,
    required this.totalCalories,
    required this.totalCarbs,
    required this.totalProtein,
    required this.totalFat,
    required this.totalWeight,
    required this.createdAt,
    this.updatedAt,
  });

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
    );
  }

  /// Creates a Hive Model from a Domain Entity.
  /// Used when preparing data to be saved into the Hive box.
  factory MealHive.fromEntity(Meal entity) {
    return MealHive(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      isTemplate: entity.isTemplate,
      consumedAt: entity.consumedAt,
      totalCalories: entity.totalCalories,
      totalCarbs: entity.totalCarbs,
      totalProtein: entity.totalProtein,
      totalFat: entity.totalFat,
      totalWeight: entity.totalWeight,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
