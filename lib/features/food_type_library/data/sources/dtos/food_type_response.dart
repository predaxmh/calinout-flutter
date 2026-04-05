import 'package:freezed_annotation/freezed_annotation.dart';

part 'food_type_response.freezed.dart';
part 'food_type_response.g.dart';

@freezed
abstract class FoodTypeResponse with _$FoodTypeResponse {
  const factory FoodTypeResponse({
    required int id,
    required String name,
    required double calories,
    required double protein,
    required double fat,
    required double carbs,
    required double baseWeightInGrams,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _FoodTypeResponse;

  factory FoodTypeResponse.fromJson(Map<String, dynamic> json) =>
      _$FoodTypeResponseFromJson(json);
}
