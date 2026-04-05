import 'package:calinout/core/utils/result.dart';
import 'package:calinout/core/utils/validators.dart';
import 'package:calinout/features/auth/data/providers/auth_providers.dart';
import 'package:calinout/features/auth/domain/models/register_request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'auth_ui_state.dart';
import 'auth_controller.dart';

part 'register_view_model.g.dart';

@riverpod
class RegisterViewModel extends _$RegisterViewModel {
  @override
  AuthUiState build() {
    return const AuthUiState.idle();
  }

  Future<void> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = const AuthUiState.idle();

    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      state = AuthUiState.error(emailError);
      return;
    }

    final passError = Validators.validatePassword(password);
    if (passError != null) {
      state = AuthUiState.error(passError);
      return;
    }

    final matchError = Validators.validateConfirmPassword(
      password,
      confirmPassword,
    );
    if (matchError != null) {
      state = AuthUiState.error(matchError);
      return;
    }

    state = const AuthUiState.loading();

    final repo = ref.read(authRepositoryProvider);

    // 2. Call Repository
    final result = await repo.register(
      RegisterRequest(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      ),
    );

    // 3. Handle Result
    switch (result) {
      case Success():
        ref.read(authControllerProvider.notifier).setAuthenticated();
        state = const AuthUiState.success();

      case Failure(:final error):
        state = AuthUiState.error(error.toString());
    }
  }
}
