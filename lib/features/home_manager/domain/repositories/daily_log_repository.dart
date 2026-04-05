import 'package:calinout/core/utils/result.dart';

import 'package:calinout/features/home_manager/domain/entities/daily_log.dart';

abstract class DailyLogRepository {
  Future<Result<DailyLog>> create(DailyLog dailyLog);
  Future<Result<(List<DailyLog>, bool)>> getAllWithSearch(
    String searchQuery,
    int page,
    int pageSize,
  );
  Future<Result<bool>> update(DailyLog dailyLog);
  Future<Result<List<DailyLog>>> getAll(int page, int pageSize);
  Future<Result<DailyLog>> getByDate(DateTime date);
  Future<Result<List<DailyLog>>> getByDateRange(DateTime start, DateTime end);
  Future<List<DailyLog>> getCachedOnly();
  Future<void> clearCache();
  bool isCacheStale();
}
