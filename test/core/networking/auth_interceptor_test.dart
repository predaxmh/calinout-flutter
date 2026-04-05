import 'package:calinout/core/networking/auth_interceptor.dart';
import 'package:calinout/features/auth/data/datasources/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([TokenStorage])
import 'auth_interceptor_test.mocks.dart';

void main() {
  late MockTokenStorage mockStorage;
  late AuthInterceptor interceptor;

  // ── Callback tracking ─────────────────────────────────────────────────────
  // We can't use @GenerateMocks for a plain Function.
  // Instead we track calls with simple counters and captured values.
  int onRefreshFailedCallCount = 0;

  setUp(() {
    mockStorage = MockTokenStorage();
    onRefreshFailedCallCount = 0;

    // ── Why create AuthInterceptor directly (no ProviderContainer) ────────
    // AuthInterceptor is not a Riverpod provider — it's a plain Dio class.
    // dio_client.dart creates it and injects its dependencies via constructor.
    // We replicate that injection here, replacing real deps with mocks.
    interceptor = AuthInterceptor(
      storage: mockStorage,
      baseUrl: 'http://test.local',
      isDebug: false,
      onTokensRefreshed: (authResponse) async {},
      onRefreshFailed: () {
        onRefreshFailedCallCount++;
      },
    );
  });

  // ── Helper: make a standard non-auth request ──────────────────────────────
  RequestOptions makeRequest({String path = '/api/v1/foods'}) =>
      RequestOptions(path: path, baseUrl: 'http://test.local');

  // ── Helper: make a 401 DioException ──────────────────────────────────────
  DioException make401Error({String path = '/api/v1/foods'}) {
    final options = makeRequest(path: path);
    return DioException(
      type: DioExceptionType.badResponse,
      requestOptions: options,
      response: Response(requestOptions: options, statusCode: 401),
    );
  }

  group('onRequest — header attachment', () {
    // ── Test 25 ──────────────────────────────────────────────────────────────
    // What: valid token (not expiring soon) → attached to Authorization header
    // Why: every authenticated request must carry the JWT.
    // If the header is missing, the API returns 401 for every call.
    // This test proves the happy path: token is read and attached correctly.
    test('attaches Bearer token to request headers', () async {
      // Arrange — token is valid, expires in 1 hour
      when(
        mockStorage.readExpiration(),
      ).thenAnswer((_) async => DateTime.now().add(const Duration(hours: 1)));
      when(
        mockStorage.readAccessToken(),
      ).thenAnswer((_) async => 'valid.jwt.token');

      final options = makeRequest();
      final handler = SpyRequestHandler();

      // Act
      await interceptor.onRequest(options, handler);

      // Assert — header was set correctly
      expect(
        options.headers['Authorization'],
        equals('Bearer valid.jwt.token'),
      );

      // handler.next() was called — request was NOT blocked
      expect(handler.nextOptions, isNotNull);
      expect(handler.rejectedError, isNull);
    });

    // ── Test 26 ──────────────────────────────────────────────────────────────
    // What: token expires within 30s → proactive refresh is triggered
    // Why: without proactive refresh, the request goes out with an almost-
    // expired token. By the time the server validates it, it might be expired,
    // causing an unexpected 401. The 30s buffer prevents this race condition.
    // This test proves the threshold check works correctly.
    //
    // Note: the refresh itself fails (no real server) → onRefreshFailed fires
    // and the request is rejected with 401. We're not testing the refresh
    // outcome here — just that the proactive trigger fires.
    test(
      'triggers proactive refresh when token expires within 30 seconds',
      () async {
        // Arrange — token expires in 10 seconds (below 30s threshold)
        when(mockStorage.readExpiration()).thenAnswer(
          (_) async => DateTime.now().add(const Duration(seconds: 10)),
        );
        when(mockStorage.readRefreshToken()).thenAnswer(
          (_) async => null,
        ); // null → _doRefresh returns false immediately

        final options = makeRequest();
        final handler = SpyRequestHandler();

        // Act
        await interceptor.onRequest(options, handler);

        // Assert — refresh was attempted (readRefreshToken was called)
        verify(mockStorage.readRefreshToken()).called(1);

        // onRefreshFailed fired because refresh returned false
        expect(onRefreshFailedCallCount, equals(1));

        // Request was rejected (not passed through with expired token)
        expect(handler.rejectedError, isNotNull);
        expect(handler.rejectedError!.response?.statusCode, equals(401));
      },
    );

    // ── Test 27 ──────────────────────────────────────────────────────────────
    // What: refresh endpoint itself is never intercepted
    // Why: _doRefresh calls POST /auth/refresh. If the interceptor
    // intercepts that call, it triggers another refresh, which triggers
    // another refresh — infinite loop. This guard is critical.
    test('never intercepts the refresh endpoint', () async {
      // Arrange — request path IS the refresh endpoint
      final options = RequestOptions(
        path: '/api/v1/auth/refresh', // matches ApiConstants.refreshToken
        baseUrl: 'http://test.local',
      );
      final handler = SpyRequestHandler();

      // Act
      await interceptor.onRequest(options, handler);

      // Assert — storage was never read, request passed through immediately
      verifyNever(mockStorage.readExpiration());
      verifyNever(mockStorage.readAccessToken());
      expect(handler.nextOptions, isNotNull);
    });
  });

  group('onError — reactive 401 handling', () {
    // ── Test 28 ──────────────────────────────────────────────────────────────
    // What: non-401 errors are passed through unchanged
    // Why: the interceptor only handles auth failures. A 500 or 404
    // must be passed to the next error handler unchanged — not swallowed.
    test('passes non-401 errors through unchanged', () async {
      final options = makeRequest();
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: options,
        response: Response(requestOptions: options, statusCode: 500),
      );
      final handler = SpyErrorHandler();

      await interceptor.onError(error, handler);

      // Error was passed through — no refresh attempt
      expect(handler.nextError, isNotNull);
      verifyNever(mockStorage.readRefreshToken());
    });

    // ── Test 29 ──────────────────────────────────────────────────────────────
    // What: 401 with no refresh token → onRefreshFailed called, error passes through
    // Why: if there's no refresh token, we can't recover. The user must log in.
    // onRefreshFailed triggers authController.logout() which redirects to login.
    test('401 with no refresh token calls onRefreshFailed', () async {
      when(mockStorage.readRefreshToken()).thenAnswer((_) async => null);

      final handler = SpyErrorHandler();
      await interceptor.onError(make401Error(), handler);

      expect(onRefreshFailedCallCount, equals(1));
      // Error is passed through — the caller sees the 401
      expect(handler.nextError, isNotNull);
    });

    // ── Test 30 — THE CONCURRENCY LOCK TEST ──────────────────────────────────
    // What: two simultaneous 401 errors only attempt one refresh
    // Why: this is the most important test in the entire suite.
    //
    // Scenario without the lock:
    //   Request A gets 401 → starts refresh
    //   Request B gets 401 → also starts refresh (before A finishes)
    //   Two refresh calls fire → server invalidates both → second refresh fails
    //   Token rotation breaks → user is logged out unexpectedly
    //
    // Scenario with the lock (_refreshCompleter):
    //   Request A gets 401 → sets _refreshCompleter, starts refresh
    //   Request B gets 401 → sees _refreshCompleter != null, awaits the SAME future
    //   Only one refresh call fires → both requests share the result
    //
    // How this test works without a real server:
    //   readRefreshToken() returns null on the first call → _doRefresh returns false
    //   We verify readRefreshToken() was called exactly once despite two concurrent 401s
    //   If the lock is broken, readRefreshToken() would be called twice
    test('concurrent 401 errors only attempt refresh once (lock test)', () async {
      // ── The timing guarantee ───────────────────────────────────────────────
      // Dart is single-threaded. When the first onError call hits
      // `await _storage.readRefreshToken()`, it suspends and yields.
      // At that exact point, _refreshCompleter is already set (non-null).
      // The second onError call then starts and sees _refreshCompleter != null
      // → it awaits the existing future instead of starting a new refresh.
      // This sequence is deterministic — no artificial delays needed.
      when(mockStorage.readRefreshToken()).thenAnswer((_) async => null);

      final handler1 = SpyErrorHandler();
      final handler2 = SpyErrorHandler();

      // Start both without awaiting — they run concurrently until their
      // first await point, which is inside _doRefresh
      final future1 = interceptor.onError(make401Error(), handler1);
      final future2 = interceptor.onError(make401Error(), handler2);

      // Wait for both to fully complete
      await Future.wait([future1, future2]);

      // THE KEY ASSERTION:
      // readRefreshToken must be called exactly once.
      // If the lock is broken: called(2)
      // If the lock works: called(1)
      verify(mockStorage.readRefreshToken()).called(1);

      // Both requests end up calling onRefreshFailed — neither can recover
      expect(onRefreshFailedCallCount, equals(2));
    });
  });
}

// ── Spy handlers ──────────────────────────────────────────────────────────────

class SpyRequestHandler extends RequestInterceptorHandler {
  RequestOptions? nextOptions;
  DioException? rejectedError;

  @override
  void next(RequestOptions options) => nextOptions = options;

  @override
  void reject(
    DioException error, [
    bool callFollowingErrorInterceptor = false,
  ]) => rejectedError = error;
}

class SpyErrorHandler extends ErrorInterceptorHandler {
  DioException? nextError;
  Response? resolvedResponse;

  @override
  void next(DioException err) => nextError = err;

  @override
  void resolve(Response response) => resolvedResponse = response;
}
