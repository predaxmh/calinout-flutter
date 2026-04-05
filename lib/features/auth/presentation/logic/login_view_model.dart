import 'package:calinout/core/utils/result.dart';
import 'package:calinout/core/utils/validators.dart';
import 'package:calinout/features/auth/data/providers/auth_providers.dart';
import 'package:calinout/features/auth/domain/models/login_request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_ui_state.dart';
import 'auth_controller.dart';

part 'login_view_model.g.dart';

@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  AuthUiState build() {
    return const AuthUiState.idle();
  }

  Future<void> login(String email, String password) async {
    state = const AuthUiState.idle();

    if (email.trim().isEmpty || password.isEmpty) {
      state = const AuthUiState.error("Please enter email and password");
      return;
    }
    String? validEmail = Validators.validateEmail(email);
    if (validEmail != null) {
      state = AuthUiState.error(validEmail);
      return;
    }

    state = const AuthUiState.loading();

    final repo = ref.read(authRepositoryProvider);

    final result = await repo.login(
      LoginRequest(email: email, password: password),
    );

    switch (result) {
      case Success():
        ref.read(authControllerProvider.notifier).setAuthenticated();

        state = const AuthUiState.success();

      case Failure(:final error):
        state = AuthUiState.error(error.toString());
    }
  }
}
