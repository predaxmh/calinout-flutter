import 'package:calinout/core/utils/network_error_parser.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Why test NetworkErrorParser ───────────────────────────────────────────────
// Every error shown to the user flows through this class.
// A wrong message here means the user sees "An unexpected error occurred"
// instead of "No internet connection" — poor UX that's hard to debug.
// These tests lock down the mapping so refactors can't silently break messages.
void main() {
  group('NetworkErrorParser.parseError', () {
    // ── Helper — builds a DioException with a given type ─────────────────────
    // DioException requires a requestOptions even for test cases.
    // We create a minimal one since the URL doesn't matter for these tests.
    DioException makeDioException(DioExceptionType type, {Response? response}) {
      return DioException(
        type: type,
        requestOptions: RequestOptions(path: '/test'),
        response: response,
      );
    }

    // ── Test 6 ───────────────────────────────────────────────────────────────
    // What: connection timeout → specific timeout message
    // Why: timeout errors are common on mobile. The user needs to know
    // it's a connectivity issue, not an app crash.
    test('connection timeout returns timeout message', () {
      final error = makeDioException(DioExceptionType.connectionTimeout);
      final result = NetworkErrorParser.parseError(error);

      expect(result, contains('timed out'));
    });

    // ── Test 7 ───────────────────────────────────────────────────────────────
    // What: connection error → no internet message
    // Why: the most common real-world failure. Different from timeout —
    // no internet means the request never started, timeout means it started
    // but didn't complete. Different root cause, different message.
    test('connection error returns no internet message', () {
      final error = makeDioException(DioExceptionType.connectionError);
      final result = NetworkErrorParser.parseError(error);

      expect(result, contains('internet'));
    });

    // ── Test 8 ───────────────────────────────────────────────────────────────
    // What: 401 response → unauthorized message
    // Why: 401 means the JWT expired or is invalid. The user needs to
    // know to log in again, not see a generic error.
    test('bad response 401 returns unauthorized message', () {
      final response = Response(
        statusCode: 401,
        requestOptions: RequestOptions(path: '/test'),
      );
      final error = makeDioException(
        DioExceptionType.badResponse,
        response: response,
      );

      final result = NetworkErrorParser.parseError(error);
      expect(result, contains('Unauthorized'));
    });

    // ── Test 9 ───────────────────────────────────────────────────────────────
    // What: 403 response → access denied message
    // Why: 403 and 401 are different. 401 = not logged in, 403 = logged in
    // but not allowed. Showing the wrong message confuses the user.
    test('bad response 403 returns access denied message', () {
      final response = Response(
        statusCode: 403,
        requestOptions: RequestOptions(path: '/test'),
      );
      final error = makeDioException(
        DioExceptionType.badResponse,
        response: response,
      );

      final result = NetworkErrorParser.parseError(error);
      expect(result, contains('denied'));
    });

    // ── Test 10 ──────────────────────────────────────────────────────────────
    // What: response body contains 'error' key → use that message directly
    // Why: your C# backend returns { "error": "Food type not found" }.
    // The parser must extract that specific message, not fall back to a
    // generic status code message. This tests the backend contract.
    test('response with error key returns backend error message', () {
      final response = Response(
        statusCode: 400,
        data: {'error': 'Food type not found'},
        requestOptions: RequestOptions(path: '/test'),
      );
      final error = makeDioException(
        DioExceptionType.badResponse,
        response: response,
      );

      final result = NetworkErrorParser.parseError(error);
      expect(result, equals('Food type not found'));
    });

    // ── Test 11 ──────────────────────────────────────────────────────────────
    // What: non-Dio error → generic message
    // Why: unexpected errors (null pointer, cast failure) must not crash
    // the app or show a raw exception message to the user.
    test('non-Dio error returns generic message', () {
      final result = NetworkErrorParser.parseError(Exception('something'));

      expect(result, contains('unexpected'));
    });
  });
}
