import 'dart:async';
import 'package:calinout/core/utils/result.dart';
import 'package:calinout/features/nutrient_logs/data/repositories/meal_repository_imp.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/meal.dart';
import 'package:calinout/features/nutrient_logs/presentation/state/meal_list_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meal_controller.g.dart';

@riverpod
class MealSearchQuery extends _$MealSearchQuery {
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
class MealController extends _$MealController {
  bool _isFetchingMore = false;

  bool get isFetchingMore => _isFetchingMore;

  @override
  FutureOr<MealListState?> build() async {
    final query = ref.watch(mealSearchQueryProvider);
    return await _fetchPage(page: 1, query: query, currentItems: []);
  }

  Future<MealListState?> _fetchPage({
    required int page,
    required String query,
    required List<Meal> currentItems,
  }) async {
    final repo = ref.read(mealRepositoryProvider);

    final result = await repo.getAllWithSearch(query, page, 10, true);

    if (!ref.mounted) return null;

    return switch (result) {
      Success(value: final value) => () {
        final (newItems, hasNext) = value;
        return MealListState(
          items: [...currentItems, ...newItems],
          hasNextPage: hasNext,
          currentPage: page,
        );
      }(),
      Failure(error: final e, stackTrace: final s) => () {
        state = AsyncValue.error(e, s ?? StackTrace.current);
        return MealListState();
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
      final query = ref.read(mealSearchQueryProvider);
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

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final query = ref.read(mealSearchQueryProvider);
    final newState = await _fetchPage(page: 1, query: query, currentItems: []);
    if (ref.mounted) {
      state = AsyncValue.data(newState);
    }
  }
}
