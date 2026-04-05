import 'package:calinout/core/database/hive_box_names.dart';
import 'package:calinout/core/database/hive_service.dart';
import 'package:calinout/features/home_manager/data/cache/models/daily_log_hive.dart';
import 'package:calinout/features/home_manager/domain/entities/daily_log.dart';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daily_log_cache_service.g.dart';

@riverpod
DailyLogCacheService dailyLogCacheService(Ref ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return DailyLogCacheService(hiveService);
}

/// Service for managing DailyLog cache operations
class DailyLogCacheService {
  final HiveService _hiveService;

  DailyLogCacheService(this._hiveService);

  /// Cache duration - adjust based on your needs
  static const Duration cacheMaxAge = Duration(hours: 1);

  Box<DailyLogHive> get _box =>
      _hiveService.getBox<DailyLogHive>(HiveBoxNames.dailyLogCache);

  /// Save a single daily log to cache
  Future<void> saveDailyLog(DailyLog dailyLog) async {
    final hiveModel = DailyLogHive.fromEntity(dailyLog);
    await _box.put(dailyLog.id, hiveModel);
  }

  /// Save multiple daily logs to cache
  Future<void> saveDailyLogs(List<DailyLog> dailyLogs) async {
    final Map<int, DailyLogHive> entries = {
      for (var log in dailyLogs) log.id: DailyLogHive.fromEntity(log),
    };
    await _box.putAll(entries);

    // Update cache timestamp
    await _hiveService.updateCacheTimestamp(
      CacheMetadataKeys.dailyLogLastFetch,
    );
  }

  /// Get a single daily log from cache
  DailyLog? getDailyLog(int id) {
    final hiveModel = _box.get(id);
    return hiveModel?.toEntity();
  }

  /// Get all cached daily logs
  List<DailyLog> getAllDailyLogs() {
    return _box.values.map((hiveModel) => hiveModel.toEntity()).toList();
  }

  /// Search cached daily logs by dailyNotes or date string
  List<DailyLog> searchDailyLogs(String query) {
    if (query.isEmpty) return getAllDailyLogs();

    final lowerQuery = query.toLowerCase();
    return _box.values
        .where((hiveModel) {
          final notes = hiveModel.dailyNotes.toLowerCase();
          final dateStr = hiveModel.date.toIso8601String().toLowerCase();
          return notes.contains(lowerQuery) || dateStr.contains(lowerQuery);
        })
        .map((hiveModel) => hiveModel.toEntity())
        .toList();
  }

  /// Get paginated cached daily logs
  /// Note: This is for cache only, API handles real pagination
  List<DailyLog> getPaginatedDailyLogs({
    String? searchQuery,
    int page = 1,
    int pageSize = 20,
  }) {
    List<DailyLog> allItems = searchQuery != null && searchQuery.isNotEmpty
        ? searchDailyLogs(searchQuery)
        : getAllDailyLogs();

    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    if (startIndex >= allItems.length) return [];
    if (endIndex >= allItems.length) {
      return allItems.sublist(startIndex);
    }

    return allItems.sublist(startIndex, endIndex);
  }

  Future<void> deleteDailyLog(int id) async {
    await _box.delete(id);
  }

  /// Clear all cached daily logs
  Future<void> clearCache() async {
    await _box.clear();
  }

  /// Check if cache is stale and needs refresh
  bool isCacheStale() {
    return _hiveService.isCacheStale(
      CacheMetadataKeys.dailyLogLastFetch,
      cacheMaxAge,
    );
  }

  /// Get cache count
  int getCacheCount() => _box.length;

  /// Check if cache is empty
  bool isCacheEmpty() => _box.isEmpty;

  /// Update cached daily log after edit
  Future<void> updateDailyLog(DailyLog dailyLog) async {
    await saveDailyLog(dailyLog);
  }
}
