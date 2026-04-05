import 'package:calinout/core/constants/api_constants.dart';
import 'package:calinout/core/networking/dio_client.dart';
import 'package:calinout/features/user_profile/data/sources/dtos/update_user_profile.dart';
import 'package:calinout/features/user_profile/data/sources/dtos/user_profile_response.dart';
import 'package:calinout/features/user_profile/data/sources/i_user_profile_api.dart';
import 'package:dio/dio.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_profile_api.g.dart';

@riverpod
IUserProfileApi userProfileApi(Ref ref) {
  final dio = ref.watch(dioProvider);
  return UserProfileApi(dio);
}

class UserProfileApi implements IUserProfileApi {
  final Dio _dio;

  UserProfileApi(this._dio);

  @override
  Future<UserProfileResponse> get() async {
    var response = await _dio.get('${ApiConstants.userProfile}/GetById');
    final pagedResponse = UserProfileResponse.fromJson(response.data);
    return pagedResponse;
  }

  @override
  Future<String> update(UpdateUserProfile updateDto) async {
    var response = await _dio.put(
      ApiConstants.userProfile,
      data: updateDto.toJson(),
    );
    return response.data;
  }
}
