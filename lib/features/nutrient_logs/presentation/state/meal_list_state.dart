import 'package:calinout/features/nutrient_logs/domain/entities/meal.dart';

class MealListState {
  final List<Meal> items;
  final bool hasNextPage;
  final int currentPage;

  MealListState({
    this.items = const [],
    this.hasNextPage = false,
    this.currentPage = 1,
  });

  MealListState copyWith({
    List<Meal>? items,
    bool? hasNextPage,
    int? currentPage,
  }) {
    return MealListState(
      items: items ?? this.items,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
