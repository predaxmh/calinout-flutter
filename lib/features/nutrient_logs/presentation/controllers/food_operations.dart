import 'package:calinout/core/utils/result.dart';
import 'package:calinout/features/nutrient_logs/data/repositories/food_repository_imp.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/food.dart';
import 'package:calinout/features/nutrient_logs/presentation/controllers/nutrition_log_controller.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'food_operations.g.dart';

@riverpod
class FoodOperations extends _$FoodOperations {
  @override
  FutureOr<Food?> build() {
    return null;
  }

  Future<void> add(Food item) async {
    if (state.isLoading) return;
    state = AsyncValue.loading();

    final repo = ref.read(foodRepositoryProvider);
    final result = await repo.create(item);
    if (!ref.mounted) return;
    switch (result) {
      case Success(value: final newFood):
        state = AsyncData(newFood);
        ref.read(nutritionLogInvalidatorProvider.notifier).invalidate();
      case Failure(error: final e, stackTrace: final s):
        state = AsyncError(e, s ?? StackTrace.current);
    }
  }

  Future<bool> updateFood(Food item) async {
    if (state.isLoading) return false;
    state = AsyncValue.loading();

    final repo = ref.read(foodRepositoryProvider);
    final result = await repo.update(item.id, item);
    if (!ref.mounted) return false;
    switch (result) {
      case Success():
        state = AsyncData(null);
        ref.read(nutritionLogInvalidatorProvider.notifier).invalidate();
      case Failure(error: final e, stackTrace: final s):
        state = AsyncError(e, s ?? StackTrace.current);
    }
    return false;
  }

  Future<bool> delete(int id) async {
    if (state.isLoading) return false;
    state = AsyncValue.loading();

    final repo = ref.read(foodRepositoryProvider);

    final result = await repo.delete(id);
    if (!ref.mounted) return true;
    switch (result) {
      case Success():
        state = AsyncData(null);
        ref.read(nutritionLogInvalidatorProvider.notifier).invalidate();
      case Failure(error: final e, stackTrace: final s):
        state = AsyncError(e, s ?? StackTrace.current);
    }
    return false;
  }
}
