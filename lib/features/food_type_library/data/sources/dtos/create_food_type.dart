import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_food_type.freezed.dart';
part 'create_food_type.g.dart';

@freezed
abstract class CreateFoodType with _$CreateFoodType {
  const factory CreateFoodType({
    required String name,
    required double calories,
    required double protein,
    required double fat,
    required double carbs,
    required double baseWeightInGrams,
  }) = _CreateFoodType;

  factory CreateFoodType.fromJson(Map<String, dynamic> json) =>
      _$CreateFoodTypeFromJson(json);
}
