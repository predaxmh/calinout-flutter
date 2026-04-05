import 'package:calinout/core/models/paged_response.dart';
import 'package:calinout/features/food_type_library/data/sources/dtos/create_food_type.dart';
import 'package:calinout/features/food_type_library/data/sources/dtos/food_type_response.dart';
import 'package:calinout/features/food_type_library/data/sources/dtos/update_food_type.dart';

abstract class IFoodTypeDatasource {
  Future<FoodTypeResponse> create(CreateFoodType createDto);
  Future<PagedResponse<FoodTypeResponse>> getAll(
    String? search,
    int page,
    int pagesize,
  );
  Future<String> update(int id, UpdateFoodType updateDto);
  Future<String> delete(int id);
}
