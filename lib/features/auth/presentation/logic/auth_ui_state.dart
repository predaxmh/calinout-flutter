import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_ui_state.freezed.dart';

@freezed
sealed class AuthUiState with _$AuthUiState {
  const factory AuthUiState.loading() = _Loading;
  const factory AuthUiState.idle() = _Idle;
  const factory AuthUiState.success() = _Success;
  const factory AuthUiState.error(String message) = _Error;
}
