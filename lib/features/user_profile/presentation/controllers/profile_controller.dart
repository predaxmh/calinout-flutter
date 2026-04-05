import 'package:calinout/core/utils/result.dart';
import 'package:calinout/features/user_profile/data/repositories/user_profile_repository_imp.dart';
import 'package:calinout/features/user_profile/domain/entities/user_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  Future<UserProfile?> build() async {
    return _fetch();
  }

  Future<UserProfile?> _fetch() async {
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.get();

    return switch (result) {
      Success(value: final profile) => profile,
      Failure(error: final e, stackTrace: final s) => () {
        state = AsyncError(e, s ?? StackTrace.current);
        return null;
      }(),
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  void updateLocal(UserProfile updated) {
    state = AsyncData(updated);
  }
}

@riverpod
class ProfileOperations extends _$ProfileOperations {
  @override
  FutureOr<UserProfile?> build() => null;

  Future<void> updateProfile(UserProfile profile) async {
    if (state.isLoading) return;
    state = const AsyncLoading();

    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.update(profile);

    if (!ref.mounted) return;

    switch (result) {
      case Success(value: final updated):
        state = AsyncData(updated);
        // Keep the fetch controller in sync so the page doesn't need to refetch.
        ref.read(profileControllerProvider.notifier).updateLocal(updated);

      case Failure(error: final e, stackTrace: final s):
        state = AsyncError(e, s ?? StackTrace.current);
    }
  }
}
