import 'package:calinout/core/logger/talker.dart';
import 'package:calinout/core/utils/result.dart';
import 'package:calinout/features/food_type_library/data/cache/food_type_cache_service.dart';
import 'package:calinout/features/food_type_library/data/sources/dtos/create_food_type.dart';
import 'package:calinout/features/food_type_library/data/sources/dtos/food_type_mapper_extension.dart';
import 'package:calinout/features/food_type_library/data/sources/dtos/update_food_type.dart';
import 'package:calinout/features/food_type_library/data/sources/food_type_api.dart';
import 'package:calinout/features/food_type_library/data/sources/i_food_type_datasource.dart';
import 'package:calinout/features/food_type_library/domain/entities/food_type.dart';
import 'package:calinout/features/food_type_library/domain/repositories/food_type_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_flutter/talker_flutter.dart';

part 'food_type_repository_imp.g.dart';

@riverpod
FoodTypeRepository foodTypeRepository(Ref ref) {
  final foodTypeApi = ref.watch(foodTypeApiProvider);
  final foodTypeCacheService = ref.watch(foodTypeCacheServiceProvider);
  final talkLogger = ref.watch(talkerProvider);
  return FoodTypeRepositoryImp(foodTypeApi, foodTypeCacheService, talkLogger);
}

class FoodTypeRepositoryImp implements FoodTypeRepository {
  final IFoodTypeDatasource _datasource;
  final FoodTypeCacheService _cacheService;
  final Talker _logger;

  FoodTypeRepositoryImp(this._datasource, this._cacheService, this._logger);

  @override
  Future<Result<FoodType>> create(FoodType foodtype) async {
    try {
      var createDto = CreateFoodType(
        name: foodtype.name,
        calories: foodtype.calories,
        protein: foodtype.protein,
        fat: foodtype.fat,
        carbs: foodtype.carbs,
        baseWeightInGrams: foodtype.baseWeightInGrams,
      );

      final responseDto = await _datasource.create(createDto);
      final foodTypeEntity = responseDto.toEntity();

      await _cacheService.saveFoodType(foodTypeEntity);

      return Result<FoodType>.success(foodTypeEntity);
    } catch (ex, stack) {
      _logger.handle(ex, stack);
      return Result.failure(ex, stack);
    }
  }

  @override
  Future<Result<(List<FoodType>, bool)>> getAllWithSearch(
    String name,
    int page,
    int pageSize,
  ) async {
    try {
      final pagedResponseDto = await _datasource.getAll(name, page, pageSize);
      var hasNextPage = pagedResponseDto.hasNextPage;
      var foodTypesList = pagedResponseDto.items
          .map((dto) => dto.toEntity())
          .toList();

      // only cache the first page
      if (page == 1 && name.isEmpty) {
        await _cacheService.saveFoodTypes(foodTypesList);
      }

      return Result.success((foodTypesList, hasNextPage));
    } catch (ex, stack) {
      _logger.handle(ex, stack);

      // Fallback to cache if API fails
      if (_cacheService.isCacheEmpty()) {
        return Result.failure(ex, stack);
      }

      // Return cached data with a flag indicating no next page
      final cachedList = name.isNotEmpty
          ? _cacheService.searchFoodTypes(name)
          : _cacheService.getPaginatedFoodTypes(page: page, pageSize: pageSize);

      _logger.info('Using cached data: ${cachedList.length} items');
      return Result.success((cachedList, false));
    }
  }

  @override
  Future<Result<bool>> delete(int id) async {
    try {
      await _datasource.delete(id);

      // Remove from cache on successful deletion
      await _cacheService.deleteFoodType(id);

      return Result<bool>.success(true);
    } catch (ex, stack) {
      _logger.handle(ex, stack);
      return Result.failure(ex, stack);
    }
  }

  @override
  Future<Result<bool>> update(int id, FoodType foodtype) async {
    try {
      var updateDto = UpdateFoodType(
        id: foodtype.id,
        name: foodtype.name,
        calories: foodtype.calories,
        protein: foodtype.protein,
        fat: foodtype.fat,
        carbs: foodtype.carbs,
        baseWeightInGrams: foodtype.baseWeightInGrams,
      );

      await _datasource.update(id, updateDto);

      // Update cache with modified item
      await _cacheService.updateFoodType(foodtype);

      return Result<bool>.success(true);
    } catch (ex, stack) {
      _logger.handle(ex, stack);
      return Result.failure(ex, stack);
    }
  }

  @override
  Future<Result<List<FoodType>>> getAll(int page, int pageSize) async {
    try {
      final pagedResponseDto = await _datasource.getAll(null, page, pageSize);

      var foodTypesList = pagedResponseDto.items
          .map((dto) => dto.toEntity())
          .toList();

      // Cache first page results
      if (page == 1) {
        await _cacheService.saveFoodTypes(foodTypesList);
      }

      return Result.success(foodTypesList);
    } catch (ex, stack) {
      _logger.handle(ex, stack);

      // Fallback to cache if API fails
      if (_cacheService.isCacheEmpty()) {
        return Result.failure(ex, stack);
      }

      final cachedList = _cacheService.getPaginatedFoodTypes(
        page: page,
        pageSize: pageSize,
      );

      _logger.info('Using cached data: ${cachedList.length} items');
      return Result.success(cachedList);
    }
  }

  @override
  Future<List<FoodType>> getCachedOnly() async {
    return _cacheService.getAllFoodTypes();
  }

  @override
  Future<void> clearCache() async {
    await _cacheService.clearCache();
  }

  @override
  bool isCacheStale() {
    return _cacheService.isCacheStale();
  }
}
