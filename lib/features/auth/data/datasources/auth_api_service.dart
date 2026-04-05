import 'package:calinout/core/constants/api_constants.dart';
import 'package:calinout/features/auth/domain/models/auth_response.dart';
import 'package:calinout/features/auth/domain/models/login_request.dart';
import 'package:calinout/features/auth/domain/models/refresh_request.dart';
import 'package:calinout/features/auth/domain/models/register_request.dart';
import 'package:dio/dio.dart';

class AuthApiService {
  final Dio _dio;

  AuthApiService(this._dio);

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: request.toJson(),
    );

    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _dio.post(
      ApiConstants.register,
      data: request.toJson(),
    );

    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> refresh(RefreshRequest request) async {
    final response = await _dio.post(
      ApiConstants.refreshToken,
      data: request.toJson(),
    );

    return AuthResponse.fromJson(response.data);
  }

  Future<void> logout(RefreshRequest request) async {
    await _dio.post(ApiConstants.logout, data: request.toJson());
  }
}
