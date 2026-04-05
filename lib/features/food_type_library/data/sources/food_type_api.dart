import 'package:calinout/core/constants/api_constants.dart';
import 'package:calinout/core/models/paged_response.dart';
import 'package:calinout/core/networking/dio_client.dart';
import 'package:calinout/features/food_type_library/data/sources/dtos/create_food_type.dart';
import 'package:calinout/features/food_type_library/data/sources/dtos/food_type_response.dart';
import 'package:calinout/features/food_type_library/data/sources/dtos/update_food_type.dart';
import 'package:calinout/features/food_type_library/data/sources/i_food_type_datasource.dart';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'food_type_api.g.dart';

@riverpod
IFoodTypeDatasource foodTypeApi(Ref ref) {
  final dio = ref.watch(dioProvider);
  return FoodTypeApi(dio);
}

class FoodTypeApi implements IFoodTypeDatasource {
  final Dio _dio;

  FoodTypeApi(this._dio);

  @override
  Future<FoodTypeResponse> create(CreateFoodType createFoodTypeDto) async {
    var response = await _dio.post(
      ApiConstants.foodTypesEndPoint,
      data: createFoodTypeDto.toJson(),
    );
    final foodTypeResponse = FoodTypeResponse.fromJson(response.data);
    return foodTypeResponse;
  }

  @override
  Future<String> delete(int id) async {
    var response = await _dio.delete('${ApiConstants.foodTypesEndPoint}/$id');
    return response.data;
  }

  @override
  Future<PagedResponse<FoodTypeResponse>> getAll(
    String? search,
    int page,
    int pagesize,
  ) async {
    var response = await _dio.get(
      ApiConstants.foodTypesEndPoint,
      queryParameters: {'search': search, 'page': page, 'pageSize': pagesize},
    );
    final pagedResponse = PagedResponse<FoodTypeResponse>.fromJson(
      response.data,
      (json) => FoodTypeResponse.fromJson(json as Map<String, dynamic>),
    );

    return pagedResponse;
  }

  @override
  Future<String> update(int id, UpdateFoodType updateFoodTypeDto) async {
    var response = await _dio.put(
      '${ApiConstants.foodTypesEndPoint}/$id',
      data: updateFoodTypeDto.toJson(),
    );
    return response.data;
  }
}
