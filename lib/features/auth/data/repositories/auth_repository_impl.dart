import 'package:calinout/core/utils/network_error_parser.dart';
import 'package:calinout/core/utils/result.dart';
import 'package:calinout/features/auth/data/datasources/auth_api_service.dart';
import 'package:calinout/features/auth/data/datasources/token_storage.dart';
import 'package:calinout/features/auth/domain/models/login_request.dart';
import 'package:calinout/features/auth/domain/models/refresh_request.dart';
import 'package:calinout/features/auth/domain/models/register_request.dart';
import 'package:calinout/features/auth/domain/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;
  final TokenStorage _storage;
  final Talker _talkerLog;

  AuthRepositoryImpl(this._apiService, this._storage, this._talkerLog);

  @override
  Future<Result<void>> login(LoginRequest request) async {
    try {
      final response = await _apiService.login(request);

      // Save tokens securely
      await _storage.saveTokens(
        response.accessToken,
        response.accessTokenExpiresAt,
        response.refreshToken,
      );

      _talkerLog.info('✅ Repo: Login success for ${request.email}');
      return const Result.success(null);
    } on DioException catch (e) {
      _talkerLog.warning(
        '⚠️ Repo: Login failed (API Error): ${e.error} ${e.message}',
      );
      return Result.failure(_handleDioError(e));
    } catch (e, stack) {
      _talkerLog.error('❌ Repo: Login system error', e, stack);
      return Result.failure(Exception("Unexpected system error"));
    }
  }

  @override
  Future<Result<void>> register(RegisterRequest request) async {
    try {
      final response = await _apiService.register(request);
      await _storage.saveTokens(
        response.accessToken,
        response.accessTokenExpiresAt,
        response.refreshToken,
      );

      _talkerLog.info('✅ Repo: Register success for ${request.email}');
      return const Result.success(null);
    } on DioException catch (e) {
      _talkerLog.warning('⚠️ Repo: Register failed: ${e.error} ${e.message}');
      return Result.failure(NetworkErrorParser.parseError(e));
    } catch (e, stack) {
      _talkerLog.error('❌ Repo: Register system error', e, stack);
      return Result.failure(NetworkErrorParser.parseError(e));
    }
  }

  @override
  Future<Result<void>> refreshToken() async {
    try {
      // 1. Get existing refresh token
      final currentRefreshToken = await _storage.readRefreshToken();

      if (currentRefreshToken == null) {
        _talkerLog.warning('⚠️ Repo: No refresh token found in storage');
        return Result.failure(Exception("No token found"));
      }

      // 2. Call API
      final response = await _apiService.refresh(
        RefreshRequest(refreshToken: currentRefreshToken),
      );

      // 3. Save NEW tokens
      await _storage.saveTokens(
        response.accessToken,
        response.accessTokenExpiresAt,
        response.refreshToken,
      );

      _talkerLog.info('✅ Repo: Token refreshed successfully');
      return const Result.success(null);
    } on DioException catch (e) {
      // If refresh fails, we often want to clear storage to force login
      await _storage.clearTokens();
      _talkerLog.warning(
        '⚠️ Repo: Refresh failed, tokens cleared: ${e.error}\n${e.message}',
      );

      //_handleDioError(e) private custom method below check it
      return Result.failure(_handleDioError(e));
    } catch (e) {
      await _storage.clearTokens();

      return Result.failure(Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken != null) {
      RefreshRequest request = RefreshRequest(refreshToken: refreshToken);
      try {
        await _apiService.logout(request);
      } on DioException catch (e) {
        Result.failure(NetworkErrorParser.parseError(e));
      } catch (e) {
        Result.failure(NetworkErrorParser.parseError(e));
      }
    }

    await _storage.clearTokens();
    _talkerLog.info('👋 Repo: User logged out locally');
    return const Result.success(null);
  }

  // Helper to extract clean error messages from API
  Exception _handleDioError(DioException e) {
    final serverMessage = e.response?.data?.toString();
    return Exception(serverMessage ?? 'Network error: ${e.error}');
  }

  @override
  Future<bool> hasRefreshToken() {
    return _storage.hasRefreshToken();
  }
}
