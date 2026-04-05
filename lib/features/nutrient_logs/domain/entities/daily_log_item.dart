import 'package:calinout/features/nutrient_logs/domain/entities/food.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/meal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_log_item.freezed.dart';

@freezed
class DailyLogItem with _$DailyLogItem {
  const factory DailyLogItem.food(Food food) = FoodLogItem;
  const factory DailyLogItem.meal(Meal meal) = MealLogItem;
}
