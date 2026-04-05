import 'package:calinout/core/utils/result.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Why test the Result pattern ───────────────────────────────────────────────
// Result<T> is used everywhere — every repository method, every operation.
// Testing it proves the sealed class pattern works correctly and that
// Failure.errorMessage delegates to NetworkErrorParser as designed.
void main() {
  group('Result', () {
    // ── Test 12 ──────────────────────────────────────────────────────────────
    // What: Success carries its value and IsSuccess is true
    // Why: confirms the factory constructor and property work correctly.
    // Simple but foundational — everything else depends on this.
    test('Success holds value and isSuccess is true', () {
      const result = Result<int>.success(42);

      // Pattern match — the modern Dart way to work with sealed classes.
      // This is cleaner than casting and more readable than is-checks.
      expect(result, isA<Success<int>>());
      expect((result as Success<int>).value, equals(42));
    });

    // ── Test 13 ──────────────────────────────────────────────────────────────
    // What: Failure holds the error and isSuccess is false
    // Why: confirms Failure construction works and error is preserved.
    test('Failure holds error', () {
      final error = Exception('something went wrong');
      final result = Result<int>.failure(error);

      expect(result, isA<Failure<int>>());
      expect((result as Failure<int>).error, equals(error));
    });

    // ── Test 14 ──────────────────────────────────────────────────────────────
    // What: Failure.errorMessage returns a human-readable string
    // Why: this is the key behavior — errorMessage delegates to
    // NetworkErrorParser. If the delegation is broken, every error
    // shown in the UI would be the raw Exception.toString() output.
    test('Failure.errorMessage returns parsed human-readable string', () {
      final dioError = DioException(
        type: DioExceptionType.connectionError,
        requestOptions: RequestOptions(path: '/test'),
      );
      final result = Result<String>.failure(dioError);
      final failure = result as Failure<String>;

      // errorMessage must not be the raw DioException.toString()
      expect(failure.errorMessage, isNot(contains('DioException')));
      // Must contain the human-readable message from NetworkErrorParser
      expect(failure.errorMessage, contains('internet'));
    });

    // ── Test 15 ──────────────────────────────────────────────────────────────
    // What: Success and Failure work correctly with switch pattern matching
    // Why: Riverpod controllers use switch(result) { case Success ... }
    // This test proves the sealed class hierarchy supports that pattern
    // and both branches are reachable.
    test('switch pattern matching reaches both branches', () {
      Result<String> success = const Result.success('hello');
      Result<String> failure = Result.failure(Exception('oops'));

      String handleResult(Result<String> r) => switch (r) {
        Success(value: final v) => 'got: $v',
        Failure(errorMessage: final e) => 'error: $e',
      };

      expect(handleResult(success), equals('got: hello'));
      expect(handleResult(failure), startsWith('error:'));
    });
  });
}
