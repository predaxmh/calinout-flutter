import 'package:calinout/core/utils/result.dart';
import 'package:calinout/features/auth/domain/repositories/auth_repository.dart';
import 'package:calinout/features/auth/data/providers/auth_providers.dart';
import 'package:calinout/features/auth/presentation/logic/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([AuthRepository])
import 'auth_controller_test.mocks.dart';

void main() {
  late MockAuthRepository mockRepo;
  late ProviderContainer container;

  // ── provideDummy ──────────────────────────────────────────────────────────
  // Result<void> is used by refreshToken() and logout().
  // Mockito needs a fallback for this type.
  setUpAll(() {
    provideDummy<Result<void>>(const Result.success(null));
  });

  setUp(() {
    mockRepo = MockAuthRepository();

    // ── Why we override authRepositoryProvider ────────────────────────────
    // AuthController.build() calls ref.read(authRepositoryProvider).
    // Without the override, Riverpod would try to build the real
    // AuthRepositoryImpl which depends on Dio, TokenStorage, and
    // FlutterSecureStorage — all platform plugins that don't run in tests.
    // The override replaces the entire dependency tree with our mock.
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
    );
  });

  tearDown(() => container.dispose());

  group('AuthController.build — app startup auth check', () {
    // ── Test 20 ──────────────────────────────────────────────────────────────
    // What: no refresh token stored → unauthenticated immediately
    // Why: a fresh install has no tokens. The controller must not attempt
    // a refresh (which would fail and potentially crash) — it must return
    // unauthenticated right away so the router redirects to welcome.
    test('no refresh token returns unauthenticated', () async {
      // Arrange — no token in storage
      when(mockRepo.hasRefreshToken()).thenAnswer((_) async => false);

      // Act — read the future of the async provider
      // .future waits for the async build() to complete
      final status = await container.read(authControllerProvider.future);

      // Assert
      expect(status, equals(AuthStatus.unauthenticated));

      // Verify refreshToken was NEVER called — no token means no refresh attempt
      verifyNever(mockRepo.refreshToken());
    });

    // ── Test 21 ──────────────────────────────────────────────────────────────
    // What: has refresh token + refresh succeeds → authenticated
    // Why: the happy path for returning users. App opens, finds a token,
    // silently refreshes it, and the user lands on home without logging in.
    // This is the silent authentication flow.
    test(
      'has refresh token and refresh succeeds returns authenticated',
      () async {
        // Arrange
        when(mockRepo.hasRefreshToken()).thenAnswer((_) async => true);
        when(
          mockRepo.refreshToken(),
        ).thenAnswer((_) async => const Result.success(null));

        // Act
        final status = await container.read(authControllerProvider.future);

        // Assert
        expect(status, equals(AuthStatus.authenticated));
        verify(mockRepo.refreshToken()).called(1);
      },
    );

    // ── Test 22 ──────────────────────────────────────────────────────────────
    // What: has refresh token but refresh fails → unauthenticated
    // Why: refresh tokens expire (e.g. user was inactive for 30 days).
    // The controller must handle this gracefully and send the user to login,
    // not crash or leave the app in a loading state forever.
    test(
      'has refresh token but refresh fails returns unauthenticated',
      () async {
        // Arrange
        when(mockRepo.hasRefreshToken()).thenAnswer((_) async => true);
        when(
          mockRepo.refreshToken(),
        ).thenAnswer((_) async => Result.failure(Exception('Token expired')));

        // Act
        final status = await container.read(authControllerProvider.future);

        // Assert
        expect(status, equals(AuthStatus.unauthenticated));
      },
    );
  });

  group('AuthController.setAuthenticated', () {
    // ── Test 23 ──────────────────────────────────────────────────────────────
    // What: setAuthenticated() sets state to authenticated
    // Why: LoginViewModel and RegisterViewModel call this after a successful
    // login/register. GoRouterNotifier listens to the controller and
    // redirects to home. If this method doesn't work, auth never completes.
    test('sets state to AsyncData authenticated', () async {
      // Arrange — start from unauthenticated
      when(mockRepo.hasRefreshToken()).thenAnswer((_) async => false);
      await container.read(authControllerProvider.future);

      // Act
      container.read(authControllerProvider.notifier).setAuthenticated();

      // Assert — state is now authenticated
      // We don't use .future here because setAuthenticated() is synchronous
      final state = container.read(authControllerProvider);
      expect(state, isA<AsyncData<AuthStatus>>());
      expect(state.value, equals(AuthStatus.authenticated));
    });
  });

  group('AuthController.logout', () {
    // ── Test 24 ──────────────────────────────────────────────────────────────
    // What: logout() calls repo.logout() and sets state to unauthenticated
    // Why: logout must clear tokens from storage (via repo.logout()) AND
    // update the state so GoRouter redirects to welcome.
    // If repo.logout() is never called, tokens remain in storage —
    // the next app start would find them and re-authenticate silently.
    test('calls repo logout and sets state to unauthenticated', () async {
      // Arrange — start from authenticated
      when(mockRepo.hasRefreshToken()).thenAnswer((_) async => true);
      when(
        mockRepo.refreshToken(),
      ).thenAnswer((_) async => const Result.success(null));
      when(
        mockRepo.logout(),
      ).thenAnswer((_) async => const Result.success(null));
      await container.read(authControllerProvider.future);

      // Act
      await container.read(authControllerProvider.notifier).logout();

      // Assert
      final state = container.read(authControllerProvider);
      expect(state.value, equals(AuthStatus.unauthenticated));

      // Verify repo.logout() was actually called — not just state change
      verify(mockRepo.logout()).called(1);
    });
  });
}
