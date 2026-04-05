import 'package:calinout/features/food_type_library/domain/entities/food_type.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

part 'food_type_hive.g.dart';

/// Hive model for caching FoodType entities
/// TypeId should be unique across your app (0-223 ce more)
@HiveType(typeId: 0)
class FoodTypeHive extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double calories;

  @HiveField(3)
  final double protein;

  @HiveField(4)
  final double fat;

  @HiveField(5)
  final double carbs;

  @HiveField(6)
  final double baseWeightInGrams;

  @HiveField(7)
  final DateTime? createdAt;

  @HiveField(8)
  final DateTime? updatedAt;

  FoodTypeHive({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.baseWeightInGrams,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert from domain entity to Hive model
  factory FoodTypeHive.fromEntity(FoodType entity) {
    return FoodTypeHive(
      id: entity.id,
      name: entity.name,
      calories: entity.calories,
      protein: entity.protein,
      fat: entity.fat,
      carbs: entity.carbs,
      baseWeightInGrams: entity.baseWeightInGrams,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert from Hive model to domain entity
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
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() {
    return 'FoodTypeHive(id: $id, name: $name)';
  }
}
