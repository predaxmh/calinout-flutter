import 'package:calinout/features/nutrient_logs/data/sources/dtos/food_dtos/create_food_request.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_meal_request.freezed.dart';
part 'create_meal_request.g.dart';

@freezed
abstract class CreateMealRequest with _$CreateMealRequest {
  const factory CreateMealRequest({
    required String name,
    @Default(false) bool isTemplate,
    DateTime? consumedAt,
    List<int>? foodIds,
    List<CreateFoodRequest>? foods,
  }) = _CreateMealRequest;

  factory CreateMealRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateMealRequestFromJson(json);
}
