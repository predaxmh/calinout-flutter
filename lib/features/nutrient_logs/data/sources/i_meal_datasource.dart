import 'package:calinout/core/models/paged_response.dart';
import 'package:calinout/features/nutrient_logs/data/sources/dtos/meal_dtos/create_meal_request.dart';
import 'package:calinout/features/nutrient_logs/data/sources/dtos/meal_dtos/meal_response.dart';
import 'package:calinout/features/nutrient_logs/data/sources/dtos/meal_dtos/update_meal_request.dart';

abstract interface class IMealDatasource {
  Future<MealResponse> create(CreateMealRequest createDto);
  Future<PagedResponse<MealResponse>> getAll(
    String? search,
    int page,
    int pageSize,
    bool? isTemplate,
  );
  Future<List<MealResponse>> getByDateRange(
    DateTime start,
    DateTime end,
    bool? isTemplate,
  );
  Future<String> update(int id, UpdateMealRequest updateDto);
  Future<String> delete(int id);
}
