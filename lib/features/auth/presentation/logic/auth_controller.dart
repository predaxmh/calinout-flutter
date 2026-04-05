import 'package:calinout/core/utils/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/auth_providers.dart';

part 'auth_controller.g.dart';

enum AuthStatus { authenticated, unauthenticated }

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  FutureOr<AuthStatus> build() async {
    return _appStartRefreshAuth();
  }

  Future<AuthStatus> _appStartRefreshAuth() async {
    final repo = ref.read(authRepositoryProvider);

    final hasRefreshToken = await repo.hasRefreshToken();

    if (!hasRefreshToken) return AuthStatus.unauthenticated;

    final result = await repo.refreshToken();

    return switch (result) {
      Success() => AuthStatus.authenticated,
      Failure() => AuthStatus.unauthenticated,
    };
  }

  // 3. Methods called by ViewModels
  void setAuthenticated() {
    state = AsyncValue.loading();
    state = AsyncValue.data(AuthStatus.authenticated);
  }

  Future<void> logout() async {
    state = AsyncValue.loading();
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = AsyncValue.data(AuthStatus.unauthenticated);
  }
}
