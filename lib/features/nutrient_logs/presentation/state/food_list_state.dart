// food_list_state.dart
import 'package:calinout/features/nutrient_logs/domain/entities/food.dart';

class FoodListState {
  final List<Food> items;
  final bool hasNextPage;
  final int currentPage;

  FoodListState({
    this.items = const [],
    this.hasNextPage = false,
    this.currentPage = 1,
  });
}
