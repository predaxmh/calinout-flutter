import 'package:calinout/core/logger/talker.dart';
import 'package:calinout/core/utils/result.dart';
import 'package:calinout/features/nutrient_logs/data/cache/food_cache_service.dart';
import 'package:calinout/features/nutrient_logs/data/sources/dtos/food_dtos/create_food_request.dart';
import 'package:calinout/features/nutrient_logs/data/sources/dtos/food_dtos/food_mapper_extention.dart';
import 'package:calinout/features/nutrient_logs/data/sources/dtos/food_dtos/update_food_request.dart';
import 'package:calinout/features/nutrient_logs/data/sources/i_food_datasource.dart';
import 'package:calinout/features/nutrient_logs/data/sources/food_api.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/food.dart';
import 'package:calinout/features/nutrient_logs/domain/repositories/food_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_flutter/talker_flutter.dart';

part 'food_repository_imp.g.dart';

@riverpod
FoodRepository foodRepository(Ref ref) {
  final foodApi = ref.watch(foodApiProvider);
  final foodCacheService = ref.watch(foodCacheServiceProvider);
  final talkLogger = ref.watch(talkerProvider);
  return FoodRepositoryImp(foodApi, foodCacheService, talkLogger);
}

class FoodRepositoryImp implements FoodRepository {
  final IFoodDatasource _datasource;
  final FoodCacheService _cacheService;
  final Talker _logger;

  FoodRepositoryImp(this._datasource, this._cacheService, this._logger);

  @override
  Future<Result<Food>> create(Food food) async {
    try {
      var createDto = CreateFoodRequest(
        foodTypeId: food.foodTypeId,
        mealId: food.mealId,
        weightInGrams: food.weightInGrams,

        isTemplate: food.isTemplate,
        consumedAt: food.consumedAt,
      );

      final responseDto = await _datasource.create(createDto);
      final foodEntity = responseDto.toEntity();

      return Result<Food>.success(foodEntity);
    } catch (ex, stack) {
      _logger.handle(ex, stack);
      return Result.failure(ex, stack);
    }
  }

  @override
  Future<Result<(List<Food>, bool)>> getAllWithSearch(
    String searchQuery,
    int page,
    int pageSize,
    bool? isTemplate,
    bool? withMealId,
  ) async {
    try {
      // Attempt API call first
      final pagedResponseDto = await _datasource.getAll(
        searchQuery,
        page,
        pageSize,
        isTemplate,
        withMealId,
      );
      var hasNextPage = pagedResponseDto.hasNextPage;
      var foodsList = pagedResponseDto.items
          .map((dto) => dto.toEntity())
          .toList();

      return Result.success((foodsList, hasNextPage));
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
  Future<Result<bool>> update(int id, Food food) async {
    try {
      var updateDto = UpdateFoodRequest(
        mealId: food.mealId,
        weightInGrams: food.weightInGrams,
        consumedAt: food.consumedAt,
      );

      await _datasource.update(id, updateDto);

      return Result<bool>.success(true);
    } catch (ex, stack) {
      _logger.handle(ex, stack);
      return Result.failure(ex, stack);
    }
  }

  @override
  Future<Result<(List<Food>, bool)>> getAll(int page, int pageSize) async {
    try {
      final pagedResponseDto = await _datasource.getAll(
        null,
        page,
        pageSize,
        false,
        false,
      );

      var foodsList = pagedResponseDto.items
          .map((dto) => dto.toEntity())
          .toList();
      final hasNextPage = pagedResponseDto.hasNextPage;
      // Cache first page results
      if (page == 1) {
        await _cacheService.saveFoods(foodsList);
      }

      return Result.success((foodsList, hasNextPage));
    } catch (ex, stack) {
      _logger.handle(ex, stack);
      return Result.failure(ex, stack);
    }
  }

  @override
  Future<List<Food>> getCachedOnly() async {
    return _cacheService.getAllFoodList();
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
  Future<Result<List<Food>>> getByDateRange(
    DateTime start,
    DateTime end,
    bool? isTemplate,
    bool? showFoodInsideMeal,
  ) async {
    try {
      final listResponse = await _datasource.getByDateRange(
        start,
        end,
        isTemplate,
        showFoodInsideMeal,
      );

      var foodsList = listResponse.map((dto) => dto.toEntity()).toList();

      return Result.success(foodsList);
    } catch (ex, stack) {
      _logger.handle(ex, stack);

      return Result.failure(ex, stack);
    }
  }
}
