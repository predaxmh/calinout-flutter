import 'package:calinout/core/presentation/widgets/double_back_card/doodle_card_list_item_data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'food_type.freezed.dart';

@freezed
abstract class FoodType with _$FoodType {
  const factory FoodType({
    required int id,
    required String name,
    required double calories,
    required double protein,
    required double fat,
    required double carbs,
    required double baseWeightInGrams,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _FoodType;
}

extension FoodTypeMapping on FoodType {
  DoodleCardListItemData toDoodleCardListItem() {
    return DoodleCardListItemData(
      time: DateTime.now(),
      name: name,
      weightValue: baseWeightInGrams,
      calorieValue: calories,
      carbValue: carbs,
      fatValue: fat,
      proteinValue: protein,
    );
  }
}
