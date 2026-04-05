import 'package:calinout/core/constants/api_constants.dart';
import 'package:calinout/core/models/paged_response.dart';
import 'package:calinout/core/networking/dio_client.dart';
import 'package:calinout/features/nutrient_logs/data/sources/dtos/food_dtos/create_food_request.dart';
import 'package:calinout/features/nutrient_logs/data/sources/dtos/food_dtos/food_response.dart';
import 'package:calinout/features/nutrient_logs/data/sources/dtos/food_dtos/update_food_request.dart';

import 'package:calinout/features/nutrient_logs/data/sources/i_food_datasource.dart';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'food_api.g.dart';

@riverpod
IFoodDatasource foodApi(Ref ref) {
  final dio = ref.watch(dioProvider);
  return FoodApi(dio);
}

class FoodApi implements IFoodDatasource {
  final Dio _dio;

  FoodApi(this._dio);

  @override
  Future<FoodResponse> create(CreateFoodRequest createFoodDto) async {
    var response = await _dio.post(
      ApiConstants.foodsEndpoint,
      data: createFoodDto.toJson(),
    );
    final foodResponse = FoodResponse.fromJson(response.data);
    return foodResponse;
  }

  @override
  Future<String> delete(int id) async {
    var response = await _dio.delete('${ApiConstants.foodsEndpoint}/$id');
    return response.data;
  }

  @override
  Future<PagedResponse<FoodResponse>> getAll(
    String? search,
    int page,
    int pageSize,
    bool? isTemplate,
    bool? withMealId,
  ) async {
    var response = await _dio.get(
      "${ApiConstants.foodsEndpoint}/GetUserFoods",
      queryParameters: {
        'search': search,
        'page': page,
        'pageSize': pageSize,
        'isTemplate': isTemplate,
        'withMealId': withMealId,
      },
    );
    final pagedResponse = PagedResponse<FoodResponse>.fromJson(
      response.data,
      (json) => FoodResponse.fromJson(json as Map<String, dynamic>),
    );

    return pagedResponse;
  }

  @override
  Future<String> update(int id, UpdateFoodRequest updateFoodDto) async {
    var response = await _dio.put(
      '${ApiConstants.foodsEndpoint}/$id',
      data: updateFoodDto.toJson(),
    );
    return response.data;
  }

  @override
  Future<List<FoodResponse>> getByDateRange(
    DateTime start,
    DateTime end,
    bool? isTemplate,
    bool? showFoodInsideMeal,
  ) async {
    var response = await _dio.get(
      "${ApiConstants.foodsEndpoint}/GetUserFoodsByDateRange",
      queryParameters: {
        'from': start,
        'to': end,
        'isTemplate': isTemplate,
        'showFoodInsideMeal': showFoodInsideMeal,
      },
    );

    final listJson = response.data as List<dynamic>;

    final responseList = listJson
        .map((json) => FoodResponse.fromJson(json))
        .toList();
    return responseList;
  }
}
