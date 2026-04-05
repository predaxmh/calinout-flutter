import 'dart:async';
import 'package:calinout/core/utils/result.dart';
import 'package:calinout/features/nutrient_logs/data/repositories/meal_repository_imp.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/meal.dart';
import 'package:calinout/features/nutrient_logs/presentation/state/meal_list_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'template_meal_controller.g.dart';

@riverpod
class TemplateMealSearchQuery extends _$TemplateMealSearchQuery {
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
class TemplateMealController extends _$TemplateMealController {
  bool _isFetchingMore = false;

  @override
  FutureOr<MealListState?> build() async {
    final query = ref.watch(templateMealSearchQueryProvider);
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
      final query = ref.read(templateMealSearchQueryProvider);
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
