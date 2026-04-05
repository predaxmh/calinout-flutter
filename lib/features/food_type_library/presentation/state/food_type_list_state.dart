// food_type_state.dart
import 'package:calinout/features/food_type_library/domain/entities/food_type.dart';

class FoodTypeListState {
  final List<FoodType> items;
  final bool hasNextPage;
  final int currentPage;

  FoodTypeListState({
    this.items = const [],
    this.hasNextPage = true,
    this.currentPage = 1,
  });

  FoodTypeListState copyWith({
    List<FoodType>? items,
    bool? hasNextPage,
    int? currentPage,
  }) {
    return FoodTypeListState(
      items: items ?? this.items,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
