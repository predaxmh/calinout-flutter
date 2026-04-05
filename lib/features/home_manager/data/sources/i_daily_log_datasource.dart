import 'package:calinout/core/models/paged_response.dart';
import 'package:calinout/features/home_manager/data/sources/dtos/create_daily_log_request.dart';
import 'package:calinout/features/home_manager/data/sources/dtos/daily_log_response.dart';
import 'package:calinout/features/home_manager/data/sources/dtos/update_daily_log_request.dart';

abstract class IDailyLogDatasource {
  Future<DailyLogResponse> create(CreateDailyLogRequest createDto);
  Future<PagedResponse<DailyLogResponse>> getAll(
    String? search,
    int page,
    int pageSize,
  );

  Future<DailyLogResponse> getByDate(DateTime date);
  Future<List<DailyLogResponse>> getByDateRange(DateTime start, DateTime end);
  Future<String> update(DateTime date, UpdateDailyLogRequest updateDto);
  Future<String> delete(int id);
}
