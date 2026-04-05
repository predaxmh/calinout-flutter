import 'package:calinout/core/utils/network_error_parser.dart';

sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>._;
  const factory Result.failure(Object error, [StackTrace? stackTrace]) =
      Failure<T>._;
}

final class Success<T> extends Result<T> {
  final T value;
  const Success._(this.value);

  @override
  String toString() => 'Success(value: $value)';
}

final class Failure<T> extends Result<T> {
  final Object error;
  final StackTrace? stackTrace;

  const Failure._(this.error, [this.stackTrace]);

  String get errorMessage => NetworkErrorParser.parseError(error);

  @override
  String toString() => 'Failure(error: $error)';
}
