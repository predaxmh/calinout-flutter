import 'package:calinout/core/logger/talker.dart';
import 'package:calinout/core/utils/result.dart';
import 'package:calinout/features/nutrient_logs/data/cache/meal_cache_service.dart';
import 'package:calinout/features/nutrient_logs/data/sources/dtos/food_dtos/food_mapper_extention.dart';
import 'package:calinout/features/nutrient_logs/data/sources/dtos/meal_dtos/create_meal_request.dart';
import 'package:calinout/features/nutrient_logs/data/sources/dtos/meal_dtos/meal_mapper_extention.dart';
import 'package:calinout/features/nutrient_logs/data/sources/dtos/meal_dtos/update_meal_request.dart';
import 'package:calinout/features/nutrient_logs/data/sources/i_meal_datasource.dart';
import 'package:calinout/features/nutrient_logs/data/sources/meal_api.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/meal.dart';
import 'package:calinout/features/nutrient_logs/domain/repositories/meal_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_flutter/talker_flutter.dart';

part 'meal_repository_imp.g.dart';

@riverpod
MealRepository mealRepository(Ref ref) {
  final mealApi = ref.watch(mealApiProvider);
  final mealCacheService = ref.watch(mealCacheServiceProvider);
  final talkLogger = ref.watch(talkerProvider);
  return MealRepositoryImp(mealApi, mealCacheService, talkLogger);
}

class MealRepositoryImp implements MealRepository {
  final IMealDatasource _datasource;
  final MealCacheService _cacheService;
  final Talker _logger;

  MealRepositoryImp(this._datasource, this._cacheService, this._logger);

  @override
  Future<Result<Meal>> create(Meal meal) async {
    try {
      var createDto = CreateMealRequest(
        name: meal.name,
        isTemplate: meal.isTemplate,
        consumedAt: meal.consumedAt,
        foodIds: meal.foods?.map((food) => food.id).toList(),
        foods: meal.foods?.map((food) => food.toCreateFoodRequest()).toList(),
      );

      final responseDto = await _datasource.create(createDto);
      final mealEntity = responseDto.toEntity();

      return Result<Meal>.success(mealEntity);
    } catch (ex, stack) {
      _logger.handle(ex, stack);
      return Result.failure(ex, stack);
    }
  }

  @override
  Future<Result<(List<Meal>, bool)>> getAllWithSearch(
    String searchQuery,
    int page,
    int pageSize,
    bool? isTemplate,
  ) async {
    try {
      final pagedResponseDto = await _datasource.getAll(
        searchQuery,
        page,
        pageSize,
        isTemplate,
      );
      var hasNextPage = pagedResponseDto.hasNextPage;
      var mealsList = pagedResponseDto.items
          .map((dto) => dto.toEntity())
          .toList();

      return Result.success((mealsList, hasNextPage));
    } catch (ex, stack) {
      _logger.handle(ex, stack);

      return Result.failure(ex, stack);
    }
  }

  @override
  Future<Result<bool>> delete(int id) async {
    try {
      await _datasource.delete(id);

      return Result<bool>.success(true);
    } catch (ex, stack) {
      _logger.handle(ex, stack);
      return Result.failure(ex, stack);
    }
  }

  @override
  Future<Result<bool>> update(int id, Meal meal) async {
    try {
      var updateDto = UpdateMealRequest(
        name: meal.name,
        isTemplate: meal.isTemplate,
        consumedAt: meal.consumedAt,
        foodIds: meal.foodIds,
      );

      await _datasource.update(id, updateDto);

      return Result<bool>.success(true);
    } catch (ex, stack) {
      _logger.handle(ex, stack);
      return Result.failure(ex, stack);
    }
  }

  @override
  Future<Result<List<Meal>>> getAll(int page, int pageSize) async {
    try {
      final pagedResponseDto = await _datasource.getAll(
        null,
        page,
        pageSize,
        false,
      );

      var mealsList = pagedResponseDto.items
          .map((dto) => dto.toEntity())
          .toList();

      return Result.success(mealsList);
    } catch (ex, stack) {
      _logger.handle(ex, stack);

      return Result.failure(ex, stack);
    }
  }

  @override
  Future<List<Meal>> getCachedOnly() async {
    return _cacheService.getAllMeals();
  }

  @override
  Future<void> clearCache() async {
    await _cacheService.clearCache();
  }

  @override
  bool isCacheStale() {
    return _cacheService.isCacheStale();
  }

  @override
  Future<Result<List<Meal>>> getByDateRange(
    DateTime start,
    DateTime end,
    bool? isTemplate,
  ) async {
    try {
      final listResponse = await _datasource.getByDateRange(
        start,
        end,
        isTemplate,
      );

      var mealsList = listResponse.map((dto) => dto.toEntity()).toList();

      return Result.success(mealsList);
    } catch (ex, stack) {
      _logger.handle(ex, stack);

      return Result.failure(ex, stack);
    }
  }
}
