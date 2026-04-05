import 'package:calinout/core/constants/api_constants.dart';
import 'package:calinout/core/models/paged_response.dart';
import 'package:calinout/core/networking/dio_client.dart';
import 'package:calinout/features/home_manager/data/sources/dtos/create_daily_log_request.dart';
import 'package:calinout/features/home_manager/data/sources/dtos/daily_log_response.dart';
import 'package:calinout/features/home_manager/data/sources/dtos/update_daily_log_request.dart';
import 'package:calinout/features/home_manager/data/sources/i_daily_log_datasource.dart';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daily_log_api.g.dart';

@riverpod
IDailyLogDatasource dailyLogApi(Ref ref) {
  final dio = ref.watch(dioProvider);
  return DailyLogApi(dio);
}

class DailyLogApi implements IDailyLogDatasource {
  final Dio _dio;

  DailyLogApi(this._dio);

  @override
  Future<DailyLogResponse> create(
    CreateDailyLogRequest createDailyLogDto,
  ) async {
    var response = await _dio.post(
      ApiConstants.dailyLogsEndpoint,
      data: createDailyLogDto.toJson(),
    );
    final dailyLogResponse = DailyLogResponse.fromJson(response.data);
    return dailyLogResponse;
  }

  @override
  Future<DailyLogResponse> getByDate(DateTime date) async {
    var response = await _dio.get(
      '${ApiConstants.dailyLogsEndpoint}/GetByDate',
      queryParameters: {'date': date},
    );
    final dailyLogResponse = DailyLogResponse.fromJson(response.data);
    return dailyLogResponse;
  }

  @override
  Future<String> delete(int id) async {
    var response = await _dio.delete('${ApiConstants.dailyLogsEndpoint}/$id');
    return response.data;
  }

  @override
  Future<PagedResponse<DailyLogResponse>> getAll(
    String? search,
    int page,
    int pageSize,
  ) async {
    var response = await _dio.get(
      ApiConstants.dailyLogsEndpoint,
      queryParameters: {'search': search, 'page': page, 'pageSize': pageSize},
    );
    final pagedResponse = PagedResponse<DailyLogResponse>.fromJson(
      response.data,
      (json) => DailyLogResponse.fromJson(json as Map<String, dynamic>),
    );

    return pagedResponse;
  }

  @override
  Future<List<DailyLogResponse>> getByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    var response = await _dio.get(
      "${ApiConstants.dailyLogsEndpoint}/GetUserDailyLogRange",
      queryParameters: {'from': start, 'to': end},
    );

    final listJson = response.data as List<dynamic>;

    final responseList = listJson
        .map((json) => DailyLogResponse.fromJson(json))
        .toList();
    return responseList;
  }

  @override
  Future<String> update(
    DateTime date,
    UpdateDailyLogRequest updateDailyLogDto,
  ) async {
    var response = await _dio.put(
      ApiConstants.dailyLogsEndpoint,
      queryParameters: {'date': date},
      data: updateDailyLogDto.toJson(),
    );
    return response.data;
  }
}
