import 'dart:async';
import 'package:calinout/core/utils/result.dart';
import 'package:calinout/features/food_type_library/data/repositories/food_type_repository_imp.dart';

import 'package:calinout/features/food_type_library/domain/entities/food_type.dart';
import 'package:calinout/features/food_type_library/presentation/state/food_type_list_state.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'food_type_controller.g.dart';

@riverpod
class FoodTypeSearchQuery extends _$FoodTypeSearchQuery {
  Timer? _timer;

  @override
  String build() => "";

  void setQuery(String newQuery) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 500), () {
      state = newQuery;
    });
  }
}

@riverpod
class FoodTypeIsFetchingMore extends _$FoodTypeIsFetchingMore {
  @override
  bool build() => false;
  void set(bool v) => state = v;
}

@riverpod
class FoodTypeController extends _$FoodTypeController {
  bool _isFetchingMore = false;

  @override
  FutureOr<FoodTypeListState?> build() async {
    final query = ref.watch(foodTypeSearchQueryProvider);

    // Reset to page 1 when query changes
    return await _fetchPage(page: 1, query: query, currentItems: []);
  }

  Future<FoodTypeListState?> _fetchPage({
    required int page,
    required String query,
    required List<FoodType> currentItems,
  }) async {
    final repo = ref.read(foodTypeRepositoryProvider);
    final result = await repo.getAllWithSearch(query, page, 20);

    if (!ref.mounted) return null;
    return switch (result) {
      Success(value: final value) => () {
        final (newItems, hasNext) = value;
        return FoodTypeListState(
          items: [...currentItems, ...newItems],
          hasNextPage: hasNext,
          currentPage: page,
        );
      }(),

      Failure(error: final e, stackTrace: final s) => () {
        state = AsyncValue.error(e, s ?? StackTrace.current);
        return FoodTypeListState();
      }(),
    };
  }

  Future<void> loadNextPage() async {
    final currentState = state.value;
    if (_isFetchingMore || currentState == null || !currentState.hasNextPage) {
      return;
    }
    _isFetchingMore = true;

    ref.read(foodTypeIsFetchingMoreProvider.notifier).set(true);

    state = await AsyncValue.guard(() async {
      final query = ref.read(foodTypeSearchQueryProvider);

      if (!ref.mounted) return null;

      final result = await _fetchPage(
        page: currentState.currentPage + 1,
        query: query,
        currentItems: currentState.items,
      );
      _isFetchingMore = false;
      ref.read(foodTypeIsFetchingMoreProvider.notifier).set(false);
      return result;
    });
    _isFetchingMore = false;
  }
}
