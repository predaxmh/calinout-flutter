import 'package:calinout/core/models/paged_response.dart';
import 'package:calinout/features/nutrient_logs/data/sources/dtos/food_dtos/create_food_request.dart';
import 'package:calinout/features/nutrient_logs/data/sources/dtos/food_dtos/food_response.dart';
import 'package:calinout/features/nutrient_logs/data/sources/dtos/food_dtos/update_food_request.dart';

abstract interface class IFoodDatasource {
  Future<FoodResponse> create(CreateFoodRequest createDto);
  Future<PagedResponse<FoodResponse>> getAll(
    String? search,
    int page,
    int pageSize,
    bool? isTemplate,
    bool? withMealId,
  );

  Future<List<FoodResponse>> getByDateRange(
    DateTime start,
    DateTime end,
    bool? isTemplate,
    bool? showFoodInsideMeal,
  );
  Future<String> update(int id, UpdateFoodRequest updateDto);
  Future<String> delete(int id);
}
