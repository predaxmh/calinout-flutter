import 'package:calinout/core/constants/api_constants.dart';
import 'package:calinout/core/models/paged_response.dart';
import 'package:calinout/core/networking/dio_client.dart';
import 'package:calinout/features/nutrient_logs/data/sources/dtos/meal_dtos/create_meal_request.dart';
import 'package:calinout/features/nutrient_logs/data/sources/dtos/meal_dtos/meal_response.dart';
import 'package:calinout/features/nutrient_logs/data/sources/dtos/meal_dtos/update_meal_request.dart';

import 'package:calinout/features/nutrient_logs/data/sources/i_meal_datasource.dart';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meal_api.g.dart';

@riverpod
IMealDatasource mealApi(Ref ref) {
  final dio = ref.watch(dioProvider);
  return MealApi(dio);
}

class MealApi implements IMealDatasource {
  final Dio _dio;

  MealApi(this._dio);

  @override
  Future<MealResponse> create(CreateMealRequest createMealDto) async {
    var response = await _dio.post(
      ApiConstants.mealsEndpoint,
      data: createMealDto.toJson(),
    );
    final mealResponse = MealResponse.fromJson(response.data);
    return mealResponse;
  }

  @override
  Future<String> delete(int id) async {
    var response = await _dio.delete('${ApiConstants.mealsEndpoint}/$id');
    return response.data;
  }

  @override
  Future<PagedResponse<MealResponse>> getAll(
    String? search,
    int page,
    int pageSize,
    bool? isTemplate,
  ) async {
    var response = await _dio.get(
      '${ApiConstants.mealsEndpoint}/GetUserMeals/',
      queryParameters: {
        'search': search,
        'page': page,
        'pageSize': pageSize,
        'isTemplate': isTemplate,
      },
    );

    final pagedResponse = PagedResponse<MealResponse>.fromJson(
      response.data,
      (json) => MealResponse.fromJson(json as Map<String, dynamic>),
    );

    return pagedResponse;
  }

  @override
  Future<String> update(int id, UpdateMealRequest updateMealDto) async {
    var response = await _dio.put(
      '${ApiConstants.mealsEndpoint}/Update/$id',
      data: updateMealDto.toJson(),
    );
    return response.data;
  }

  @override
  Future<List<MealResponse>> getByDateRange(
    DateTime start,
    DateTime end,
    bool? isTemplate,
  ) async {
    var response = await _dio.get(
      "${ApiConstants.mealsEndpoint}/GetUserMealsByDateRange",
      queryParameters: {'from': start, 'to': end, 'isTemplate': isTemplate},
    );

    final listJson = response.data as List<dynamic>;

    final responseList = listJson
        .map((json) => MealResponse.fromJson(json))
        .toList();
    return responseList;
  }
}
