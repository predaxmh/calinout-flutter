import 'package:calinout/core/utils/date_utils.dart';
import 'package:calinout/core/utils/result.dart';
import 'package:calinout/features/home_manager/data/repositories/daily_log_repository_imp.dart';
import 'package:calinout/features/home_manager/domain/entities/daily_log.dart';
import 'package:calinout/features/home_manager/presentation/state/extra_data_state.dart';
import 'package:calinout/features/nutrient_logs/presentation/controllers/nutrition_log_controller.dart';
import 'package:calinout/features/user_profile/domain/entities/user_profile.dart';
import 'package:calinout/features/user_profile/presentation/controllers/profile_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daily_log_controller.g.dart';

@riverpod
class ExtraDataControl extends _$ExtraDataControl {
  @override
  ExtraDataState? build() {
    UserProfile? profileInfo = ref.watch(profileControllerProvider).value;
    DailyLog? dailyLog = ref.watch(dailyLogControllerProvider).value;

    return _calculateExtraData(profileInfo, dailyLog);
  }

  ExtraDataState _calculateExtraData(UserProfile? profile, DailyLog? dailyLog) {
    int bodyBaseCalories = 0;

    // Early return if critical data missing
    if (profile?.weightInKg == null ||
        profile?.heightInCm == null ||
        profile?.birthDate == null ||
        profile?.gender == null) {
      // Or set to 0 / throw / return default state
      return ExtraDataState(bodyBaseCalories: 0, maintenanceCalories: 0);
    }

    final now = DateTime.now();
    final age =
        now.year -
        profile!.birthDate!.year -
        (now.month < profile.birthDate!.month ||
                (now.month == profile.birthDate!.month &&
                    now.day < profile.birthDate!.day)
            ? 1
            : 0);

    final weight = dailyLog?.weightAtLog ?? profile.weightInKg!;
    final height = profile.heightInCm!;

    // Mifflin-St Jeor
    if (profile.gender == Gender.male) {
      bodyBaseCalories = ((10 * weight) + (6.25 * height) - (5 * age) + 5)
          .round();
    } else if (profile.gender == Gender.female) {
      bodyBaseCalories = ((10 * weight) + (6.25 * height) - (5 * age) - 161)
          .round();
    }

    // Maintenance = base (BMR) + tracked activity burn
    final maintenanceCalories =
        bodyBaseCalories + (dailyLog?.burnedCalories ?? 0);

    return ExtraDataState(
      bodyBaseCalories: bodyBaseCalories,
      maintenanceCalories: maintenanceCalories,
    );
  }
}

@Riverpod(keepAlive: true)
class DailyLogController extends _$DailyLogController {
  @override
  FutureOr<DailyLog?> build() async {
    ref.watch(nutritionLogInvalidatorProvider);
    final dateTime = DateTime.now();
    final todayDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    return _fetch(todayDate);
  }

  Future<DailyLog?> _fetch(DateTime today) async {
    if (state.isLoading) null;
    state = AsyncValue.loading();
    final result = await ref.read(dailyLogRepositoryProvider).getByDate(today);

    switch (result) {
      case Success(:final value):
        return value;
      case Failure(:final error, :var stackTrace):
        state = AsyncValue.error(error, stackTrace ?? StackTrace.current);
        return null;
    }
  }

  Future<void> updateWeight(double? weight, DateTime date) async {
    final repo = ref.read(dailyLogRepositoryProvider);

    DailyLog? log;

    if (isSameDay(date, DateTime.now())) {
      log = state.value;
    } else {
      final result = await repo.getByDate(date);
      switch (result) {
        case Success(value: final fetchedLog):
          log = fetchedLog;
        case Failure(:final error, :final stackTrace):
          state = AsyncValue.error(error, stackTrace ?? StackTrace.current);
          return;
      }
    }

    if (log == null) return;

    final updated = log.copyWith(weightAtLog: weight);
    final result = await repo.update(updated);

    switch (result) {
      case Success():
        if (isSameDay(date, DateTime.now())) {
          state = AsyncValue.data(updated);
        }
      case Failure(:final error, :final stackTrace):
        state = AsyncValue.error(error, stackTrace ?? StackTrace.current);
    }
  }

  Future<void> toggleDigestiveTrack() async {
    final repo = ref.read(dailyLogRepositoryProvider);

    final changeDigestiveTrack = state.value!.digestiveTrackCleared
        ? false
        : true;
    final updateLog = state.value!.copyWith(
      digestiveTrackCleared: changeDigestiveTrack,
    );

    final result = await repo.update(updateLog);

    switch (result) {
      case Success():
        state = AsyncValue.data(
          state.value!.copyWith(digestiveTrackCleared: changeDigestiveTrack),
        );
      case Failure(:final errorMessage, :final stackTrace):
        state = AsyncValue.error(
          errorMessage,
          stackTrace ?? StackTrace.current,
        );
    }
  }

  Future<void> toggleCheatDay() async {
    final repo = ref.read(dailyLogRepositoryProvider);

    final changeIscheatDay = state.value!.isCheatDay ? false : true;
    final updateLog = state.value!.copyWith(isCheatDay: changeIscheatDay);

    final result = await repo.update(updateLog);

    switch (result) {
      case Success():
        //ref.invalidateSelf();
        state = AsyncValue.data(updateLog);
      case Failure(:final errorMessage, :final stackTrace):
        state = AsyncValue.error(
          errorMessage,
          stackTrace ?? StackTrace.current,
        );
    }
  }

  Future<void> updateDailyNote(String note) async {
    final repo = ref.read(dailyLogRepositoryProvider);

    final updateLog = state.value!.copyWith(dailyNotes: note);

    final result = await repo.update(updateLog);

    switch (result) {
      case Success():
        state = AsyncValue.data(updateLog);
      case Failure(:final errorMessage, :final stackTrace):
        state = AsyncValue.error(
          errorMessage,
          stackTrace ?? StackTrace.current,
        );
    }
  }

  Future<void> goalCaloriesSet(int goal) async {
    final repo = ref.read(dailyLogRepositoryProvider);

    final updateLog = state.value!.copyWith(targetCalorieOnThisDay: goal);

    final result = await repo.update(updateLog);

    switch (result) {
      case Success():
        state = AsyncValue.data(updateLog);
      case Failure(:final errorMessage, :final stackTrace):
        state = AsyncValue.error(
          errorMessage,
          stackTrace ?? StackTrace.current,
        );
    }
  }

  Future<void> burnedCaloriesSet(int burendCalories) async {
    final repo = ref.read(dailyLogRepositoryProvider);

    final updateLog = state.value!.copyWith(burnedCalories: burendCalories);

    final result = await repo.update(updateLog);

    switch (result) {
      case Success():
        state = AsyncValue.data(updateLog);
      case Failure(:final errorMessage, :final stackTrace):
        state = AsyncValue.error(
          errorMessage,
          stackTrace ?? StackTrace.current,
        );
    }
  }
}
