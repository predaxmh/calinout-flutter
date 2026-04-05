import 'dart:async';
import 'package:calinout/core/utils/result.dart';
import 'package:calinout/features/nutrient_logs/data/repositories/food_repository_imp.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/food.dart';
import 'package:calinout/features/nutrient_logs/presentation/state/food_list_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'food_controller.g.dart';

@riverpod
class FoodSearchQuery extends _$FoodSearchQuery {
  Timer? _timer;

  @override
  String build() => '';

  void setQuery(String newQuery) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 500), () {
      state = newQuery;
    });
  }
}

@riverpod
class FoodController extends _$FoodController {
  bool _isFetchingMore = false;

  bool get isFetchingMore => _isFetchingMore;

  @override
  FutureOr<FoodListState?> build() async {
    final query = ref.watch(foodSearchQueryProvider);
    return await _fetchPage(page: 1, query: query, currentItems: []);
  }

  Future<FoodListState?> _fetchPage({
    required int page,
    required String query,
    required List<Food> currentItems,
  }) async {
    final repo = ref.read(foodRepositoryProvider);
    final result = await repo.getAllWithSearch(query, page, 10, true, false);

    if (!ref.mounted) return null;
    return switch (result) {
      Success(value: final value) => () {
        final (newItems, hasNext) = value;
        return FoodListState(
          items: [...currentItems, ...newItems],
          hasNextPage: hasNext,
          currentPage: page,
        );
      }(),
      Failure(error: final e, stackTrace: final s) => () {
        state = AsyncValue.error(e, s ?? StackTrace.current);
        return FoodListState();
      }(),
    };
  }

  Future<void> loadNextPage() async {
    final currentState = state.value;
    if (_isFetchingMore || currentState == null || !currentState.hasNextPage) {
      return;
    }

    _isFetchingMore = true;

    state = await AsyncValue.guard(() async {
      final query = ref.read(foodSearchQueryProvider);
      if (!ref.mounted) return null;

      final result = await _fetchPage(
        page: currentState.currentPage + 1,
        query: query,
        currentItems: currentState.items,
      );
      _isFetchingMore = false;
      return result;
    });
    _isFetchingMore = false;
  }
}
