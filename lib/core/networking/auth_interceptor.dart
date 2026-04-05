import 'dart:async';
import 'dart:io';
import 'package:calinout/core/constants/api_constants.dart';
import 'package:calinout/features/auth/data/datasources/token_storage.dart';
import 'package:calinout/features/auth/domain/models/auth_response.dart';
import 'package:calinout/features/auth/domain/models/refresh_request.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class AuthInterceptor extends Interceptor {
  final bool _isDebug;
  final TokenStorage _storage;
  final String _baseUrl;

  /// Called with the new AuthResponse after a successful refresh.
  /// Wired to tokenStorage.saveTokens(...) from dio_client.
  final Future<void> Function(AuthResponse) onTokensRefreshed;

  /// Called when refresh fails — wired to authController.logout().
  /// Using a callback (not a direct ref) avoids circular dependency:
  ///   dioProvider → authControllerProvider → authRepositoryProvider → dioProvider
  final void Function() onRefreshFailed;

  AuthInterceptor({
    required TokenStorage storage,
    required String baseUrl,
    required this.onTokensRefreshed,
    required this.onRefreshFailed,
    bool isDebug = false,
  }) : _storage = storage,
       _baseUrl = baseUrl,
       _isDebug = isDebug;

  // ── Refresh lock ───────────────────────────────────────────────────────────
  // Static so it is shared across all interceptor instances.
  // If 3 requests get 401 simultaneously, only ONE refresh call fires.
  // The other two hit `_refreshCompleter != null` and await the same future.
  static Completer<bool>? _refreshCompleter;

  // ── onRequest — proactive expiry check ────────────────────────────────────

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Never intercept the refresh endpoint — avoids infinite loop.
    if (_isRefreshRequest(options)) return handler.next(options);

    // If token expires within 30 seconds, refresh proactively so the
    // actual request goes out with a fresh token and never sees a 401.
    final expiry = await _storage.readExpiration();
    final now = DateTime.now();
    final expiresSoon =
        expiry != null && expiry.isBefore(now.add(const Duration(seconds: 30)));

    if (expiresSoon) {
      final refreshed = await _doRefresh();
      if (!refreshed) {
        onRefreshFailed();
        return handler.reject(
          DioException(
            requestOptions: options,
            response: Response(requestOptions: options, statusCode: 401),
            type: DioExceptionType.badResponse,
          ),
        );
      }
    }

    final token = await _storage.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  // ── onError — reactive 401 handling ───────────────────────────────────────

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final is401 = err.response?.statusCode == 401;

    // Only handle 401, skip auth endpoints.
    if (!is401 || _isRefreshRequest(err.requestOptions)) {
      return handler.next(err);
    }

    final refreshed = await _doRefresh();

    if (!refreshed) {
      onRefreshFailed();
      return handler.next(err);
    }

    // Retry original request with fresh token.
    // Uses a plain Dio with no interceptors to avoid re-entering this interceptor.
    try {
      final token = await _storage.readAccessToken();
      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer $token';

      final retryDio = _buildBareDio();
      final response = await retryDio.fetch(options);
      return handler.resolve(response);
    } catch (_) {
      return handler.next(err);
    }
  }

  // ── Refresh with lock ──────────────────────────────────────────────────────

  Future<bool> _doRefresh() async {
    // Already refreshing — wait for the in-flight call to resolve.
    if (_refreshCompleter != null) return _refreshCompleter!.future;

    _refreshCompleter = Completer<bool>();

    try {
      final refreshToken = await _storage.readRefreshToken();
      if (refreshToken == null) {
        _refreshCompleter!.complete(false);
        return false;
      }

      // Dedicated Dio — no interceptors, no recursion risk.
      final refreshDio = _buildBareDio();

      final response = await refreshDio.post(
        ApiConstants.refreshToken,
        data: RefreshRequest(refreshToken: refreshToken).toJson(),
      );

      final authResponse = AuthResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Persist new tokens — saveTokens(accessToken, expiresAt, refreshToken)
      await onTokensRefreshed(authResponse);

      _refreshCompleter!.complete(true);
      return true;
    } catch (e) {
      //print('❌ _doRefresh failed: $e');
      //await _storage.clearTokens();
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      // Always release the lock — even if an unexpected error is thrown.
      _refreshCompleter = null;
    }
  }

  bool _isRefreshRequest(RequestOptions options) =>
      options.path.contains(ApiConstants.refreshToken);

  Dio _buildBareDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    // Apply the same SSL bypass used on the main Dio in debug mode.
    if (_isDebug) {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        },
      );
    }
    return dio;
  }
}
