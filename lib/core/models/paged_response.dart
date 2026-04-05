import 'package:freezed_annotation/freezed_annotation.dart';

part 'paged_response.freezed.dart';
part 'paged_response.g.dart';

@Freezed(genericArgumentFactories: true)
sealed class PagedResponse<T> with _$PagedResponse<T> {
  const factory PagedResponse({
    required List<T> items,
    required int totalRecords,
    required int pageNumber,
    required int pageSize,
  }) = _PagedResponse<T>;

  // We add a private constructor to allow defining custom getters
  const PagedResponse._();

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$PagedResponseFromJson(json, fromJsonT);

  // Helper logic mirrored from your C# record
  int get totalPages =>
      (totalRecords <= pageSize) ? 1 : (totalRecords / pageSize).ceil();
  bool get hasNextPage => pageNumber < totalPages;
  bool get hasPreviousPage => pageNumber > 1;
}
