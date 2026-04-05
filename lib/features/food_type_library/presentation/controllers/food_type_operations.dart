import 'package:calinout/core/utils/result.dart';
import 'package:calinout/features/food_type_library/data/repositories/food_type_repository_imp.dart';
import 'package:calinout/features/food_type_library/domain/entities/food_type.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'food_type_operations.g.dart';

@riverpod
class FoodTypeOperations extends _$FoodTypeOperations {
  @override
  FutureOr<FoodType?> build() {
    return null;
  }

  Future<void> add(FoodType item) async {
    if (state.isLoading) return;
    state = AsyncValue.loading();

    final repo = ref.read(foodTypeRepositoryProvider);
    final result = await repo.create(item);
    if (!ref.mounted) return;
    switch (result) {
      case Success(value: final newFoodType):
        state = AsyncData(newFoodType);

      case Failure(error: final e, stackTrace: final s):
        state = AsyncError(e, s ?? StackTrace.current);
    }
  }

  Future<bool> updateFoodType(FoodType item) async {
    if (state.isLoading) return false;
    state = AsyncValue.loading();

    final repo = ref.read(foodTypeRepositoryProvider);
    final result = await repo.update(item.id, item);
    if (!ref.mounted) return false;
    switch (result) {
      case Success():
        state = AsyncData(null);

      case Failure(error: final e, stackTrace: final s):
        state = AsyncError(e, s ?? StackTrace.current);
    }
    return false;
  }

  Future<bool> delete(int id) async {
    if (state.isLoading) return false;
    state = AsyncValue.loading();

    final repo = ref.read(foodTypeRepositoryProvider);
    final result = await repo.delete(id);
    if (!ref.mounted) return true;
    switch (result) {
      case Success():
        state = AsyncData(null);

      case Failure(error: final e, stackTrace: final s):
        state = AsyncError(e, s ?? StackTrace.current);
    }
    return false;
  }
}
