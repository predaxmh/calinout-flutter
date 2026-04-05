import 'package:calinout/core/utils/result.dart';
import 'package:calinout/features/nutrient_logs/data/repositories/meal_repository_imp.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/meal.dart';
import 'package:calinout/features/nutrient_logs/presentation/controllers/nutrition_log_controller.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meal_operations.g.dart';

@riverpod
class MealOperations extends _$MealOperations {
  @override
  FutureOr<Meal?> build() {
    return null;
  }

  Future<void> add(Meal item) async {
    if (state.isLoading) return;
    state = AsyncValue.loading();

    final repo = ref.read(mealRepositoryProvider);
    final result = await repo.create(item);

    if (!ref.mounted) return;
    switch (result) {
      case Success(value: final newMeal):
        state = AsyncData(newMeal);
        ref.read(nutritionLogInvalidatorProvider.notifier).invalidate();
      case Failure(error: final e, stackTrace: final s):
        state = AsyncError(e, s ?? StackTrace.current);
    }
  }

  Future<bool> updateMeal(Meal item) async {
    if (state.isLoading) return false;
    state = AsyncValue.loading();

    final repo = ref.read(mealRepositoryProvider);
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

    final repo = ref.read(mealRepositoryProvider);

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
