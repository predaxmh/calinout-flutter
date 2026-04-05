import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_food_type.freezed.dart';
part 'update_food_type.g.dart';

@freezed
abstract class UpdateFoodType with _$UpdateFoodType {
  factory UpdateFoodType({
    required int id,
    required String name,
    required double calories,
    required double protein,
    required double fat,
    required double carbs,
    required double baseWeightInGrams,
  }) = _UpdateFoodType;

  factory UpdateFoodType.fromJson(Map<String, dynamic> json) =>
      _$UpdateFoodTypeFromJson(json);
}
