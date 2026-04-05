import 'package:calinout/core/logger/talker.dart';
import 'package:calinout/core/utils/result.dart';
import 'package:calinout/features/home_manager/data/cache/daily_log_cache_service.dart';
import 'package:calinout/features/home_manager/data/sources/daily_log_api.dart';
import 'package:calinout/features/home_manager/data/sources/dtos/create_daily_log_request.dart';
import 'package:calinout/features/home_manager/data/sources/dtos/daily_log_mapper_extention.dart';
import 'package:calinout/features/home_manager/data/sources/dtos/update_daily_log_request.dart';
import 'package:calinout/features/home_manager/data/sources/i_daily_log_datasource.dart';
import 'package:calinout/features/home_manager/domain/entities/daily_log.dart';
import 'package:calinout/features/home_manager/domain/repositories/daily_log_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_flutter/talker_flutter.dart';

part 'daily_log_repository_imp.g.dart';

@riverpod
DailyLogRepository dailyLogRepository(Ref ref) {
  final dailyLogApi = ref.watch(dailyLogApiProvider);
  final dailyLogCacheService = ref.watch(dailyLogCacheServiceProvider);
  final talkLogger = ref.watch(talkerProvider);
  return DailyLogRepositoryImp(dailyLogApi, dailyLogCacheService, talkLogger);
}

class DailyLogRepositoryImp implements DailyLogRepository {
  final IDailyLogDatasource _datasource;
  final DailyLogCacheService _cacheService;
  final Talker _logger;

  DailyLogRepositoryImp(this._datasource, this._cacheService, this._logger);

  @override
  Future<Result<DailyLog>> create(DailyLog dailyLog) async {
    try {
      var createDto = CreateDailyLogRequest(
        date: dailyLog.date,
        burnedCalories: dailyLog.burnedCalories,
        weightAtLog: dailyLog.weightAtLog,
        digestiveTrackCleared: dailyLog.digestiveTrackCleared,
        isCheatDay: dailyLog.isCheatDay,
        totalCalories: dailyLog.totalCalories,
        dailyNotes: dailyLog.dailyNotes,
        targetCalorieOnThisDay: dailyLog.targetCalorieOnThisDay,
        totalFoodWeight: dailyLog.totalFoodWeight,
        totalFat: dailyLog.totalFat,
        totalCarbs: dailyLog.totalCarbs,
        totalProtein: dailyLog.totalProtein,
      );

      final responseDto = await _datasource.create(createDto);
      final dailyLogEntity = responseDto.toEntity();

      return Result<DailyLog>.success(dailyLogEntity);
    } catch (ex, stack) {
      _logger.handle(ex, stack);
      return Result.failure(ex, stack);
    }
  }

  @override
  Future<Result<(List<DailyLog>, bool)>> getAllWithSearch(
    String searchQuery,
    int page,
    int pageSize,
  ) async {
    try {
      // Attempt API call first
      final pagedResponseDto = await _datasource.getAll(
        searchQuery,
        page,
        pageSize,
      );
      var hasNextPage = pagedResponseDto.hasNextPage;
      var dailyLogsList = pagedResponseDto.items
          .map((dto) => dto.toEntity())
          .toList();

      return Result.success((dailyLogsList, hasNextPage));
    } catch (ex, stack) {
      _logger.handle(ex, stack);
      return Result.failure(ex, stack);
    }
  }

  @override
  Future<Result<DailyLog>> getByDate(DateTime date) async {
    try {
      final dailyLogResponse = await _datasource.getByDate(date);

      final dailyLog = dailyLogResponse.toEntity();

      return Result<DailyLog>.success(dailyLog);
    } catch (ex, stack) {
      _logger.handle(ex, stack);
      return Result.failure(ex, stack);
    }
  }

  @override
  Future<Result<bool>> update(DailyLog dailyLog) async {
    try {
      var updateDto = UpdateDailyLogRequest(
        burnedCalories: dailyLog.burnedCalories,
        weightAtLog: dailyLog.weightAtLog,
        digestiveTrackCleared: dailyLog.digestiveTrackCleared,
        isCheatDay: dailyLog.isCheatDay,
        dailyNotes: dailyLog.dailyNotes,
        targetCalorieOnThisDay: dailyLog.targetCalorieOnThisDay,
      );
      DateTime dateTime = DateTime.now();
      DateTime todayDate = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
      );

      await _datasource.update(todayDate, updateDto);

      return Result<bool>.success(true);
    } catch (ex, stack) {
      _logger.handle(ex, stack);
      return Result.failure(ex, stack);
    }
  }

  @override
  Future<Result<List<DailyLog>>> getAll(int page, int pageSize) async {
    try {
      final pagedResponseDto = await _datasource.getAll(null, page, pageSize);

      var dailyLogsList = pagedResponseDto.items
          .map((dto) => dto.toEntity())
          .toList();

      return Result.success(dailyLogsList);
    } catch (ex, stack) {
      _logger.handle(ex, stack);

      return Result.failure(ex, stack);
    }
  }

  @override
  Future<List<DailyLog>> getCachedOnly() async {
    return _cacheService.getAllDailyLogs();
  }

  @override
  Future<Result<List<DailyLog>>> getByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final listResponse = await _datasource.getByDateRange(start, end);

      var dailyLogList = listResponse.map((dto) => dto.toEntity()).toList();

      return Result.success(dailyLogList);
    } catch (ex, stack) {
      _logger.handle(ex, stack);

      return Result.failure(ex, stack);
    }
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
