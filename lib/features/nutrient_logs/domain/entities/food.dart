import 'package:calinout/core/presentation/widgets/double_back_card/doodle_card_list_item_data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'food.freezed.dart';

@freezed
abstract class Food with _$Food {
  const factory Food({
    required int id,
    required String userId,
    required String name,
    required int foodTypeId,
    int? mealId,
    required double weightInGrams,
    DateTime? consumedAt,
    @Default(false) bool isTemplate,
    required double calories,
    required double protein,
    required double fat,
    required double carbs,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Food;
}

extension FoodMapping on Food {
  DoodleCardListItemData toDoodleCardListItem() {
    return DoodleCardListItemData(
      time: consumedAt ?? DateTime.now(),
      name: name,
      weightValue: weightInGrams,
      calorieValue: calories,
      carbValue: carbs,
      fatValue: fat,
      proteinValue: protein,
    );
  }
}
