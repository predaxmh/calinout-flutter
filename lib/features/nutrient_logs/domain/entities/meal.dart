import 'package:calinout/core/presentation/widgets/double_back_card/doodle_card_list_item_data.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/food.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal.freezed.dart';

@freezed
abstract class Meal with _$Meal {
  const factory Meal({
    required int id,
    required String userId,
    required String name,
    @Default(false) bool isTemplate,
    DateTime? consumedAt,
    required double totalCalories,
    required double totalCarbs,
    required double totalProtein,
    required double totalFat,
    required double totalWeight,
    required DateTime createdAt,
    List<Food>? foods,
    List<int>? foodIds,
    DateTime? updatedAt,
  }) = _Meal;
}

extension MealMapping on Meal {
  DoodleCardListItemData toDoodleCardListItem() {
    return DoodleCardListItemData(
      time: consumedAt ?? DateTime.now(),
      name: name,
      weightValue: totalWeight,
      calorieValue: totalCalories,
      carbValue: totalCarbs,
      fatValue: totalFat,
      proteinValue: totalProtein,
    );
  }
}
