import 'package:calinout/core/utils/result.dart';
import 'package:calinout/features/food_type_library/domain/entities/food_type.dart';

abstract interface class FoodTypeRepository {
  Future<Result<FoodType>> create(FoodType foodtype);
  Future<Result<List<FoodType>>> getAll(int page, int pageSize);
  Future<Result<(List<FoodType>, bool)>> getAllWithSearch(
    String name,
    int page,
    int pageSize,
  );
  Future<Result<bool>> update(int id, FoodType foodtype);
  Future<Result<bool>> delete(int id);
  Future<List<FoodType>> getCachedOnly();
  Future<void> clearCache();
  bool isCacheStale();
}
