import 'package:calinout/features/nutrient_logs/domain/entities/food.dart';
import 'package:calinout/features/nutrient_logs/domain/repositories/food_repository.dart';
import 'package:calinout/features/nutrient_logs/presentation/controllers/food_operations.dart';
import 'package:calinout/core/utils/result.dart';
import 'package:calinout/features/nutrient_logs/data/repositories/food_repository_imp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// ── Code generation annotation ────────────────────────────────────────────────
// This tells build_runner: "generate a MockFoodRepository class".
// The generated file will be named food_operations_test.mocks.dart
// and placed next to this file automatically.
// You must run: flutter pub run build_runner build
// after adding or changing this annotation.
@GenerateMocks([FoodRepository])
import 'food_operations_test.mocks.dart';

void main() {
  provideDummy<Result<Food>>(Result.failure(Exception('dummy')));
  provideDummy<Result<bool>>(Result.failure(Exception('dummy')));
  provideDummy<Result<(List<Food>, bool)>>(Result.failure(Exception('dummy')));
  provideDummy<Result<List<Food>>>(Result.failure(Exception('dummy')));
  // ── What is ProviderContainer? ────────────────────────────────────────────
  // In your Flutter app, ProviderScope sits at the root of the widget tree
  // and hosts all providers. In tests there's no widget tree.
  // ProviderContainer is the test equivalent — it hosts providers,
  // allows overrides, and lets you read/watch state directly without widgets.
  late ProviderContainer container;
  late MockFoodRepository mockRepo;

  // ── Minimal Food entity for tests ─────────────────────────────────────────
  // We need a Food object to pass to operations.add().
  // All fields must satisfy your Food entity's requirements.
  // Using a factory method keeps all tests consistent.
  Food makeFood({int id = -1}) => Food(
    id: id,
    userId: 'user-1',
    name: 'Chicken Breast',
    foodTypeId: 1,
    weightInGrams: 150,
    isTemplate: false,
    calories: 247.5,
    protein: 46.5,
    fat: 5.4,
    carbs: 0,
    createdAt: DateTime(2025, 1, 1),
    consumedAt: DateTime(2025, 1, 1),
  );

  setUp(() {
    mockRepo = MockFoodRepository();

    // ── ProviderContainer with override ───────────────────────────────────
    // overrides replaces the real foodRepositoryProvider with our mock.
    // Without this override, FoodOperations would try to create a real
    // FoodRepositoryImp which needs Dio, Hive, and a running API.
    // The override is the test equivalent of dependency injection.
    container = ProviderContainer(
      overrides: [foodRepositoryProvider.overrideWithValue(mockRepo)],
    );
  });

  // ── Dispose after each test ───────────────────────────────────────────────
  // ProviderContainer holds resources — dispose prevents memory leaks
  // and ensures state from one test doesn't bleed into the next.
  tearDown(() {
    container.dispose();
  });

  group('FoodOperations.add', () {
    // ── Test 16 ──────────────────────────────────────────────────────────────
    // What: successful create → state transitions loading → AsyncData
    // Why: proves the happy path state machine works correctly.
    // The controller must go through loading (so UI shows spinner)
    // then land on AsyncData (so UI shows success).
    // If it skips loading, the spinner never appears.
    // If it stays on loading, the button stays disabled forever.
    test('success sets state to AsyncData with created food', () async {
      // Arrange — mock returns a successful result
      final createdFood = makeFood(id: 1);
      when(
        mockRepo.create(any),
      ).thenAnswer((_) async => Result.success(createdFood));

      // Act
      await container.read(foodOperationsProvider.notifier).add(makeFood());

      // Assert — final state is AsyncData containing the created food
      final state = container.read(foodOperationsProvider);
      expect(state, isA<AsyncData<Food?>>());
      expect(state.value?.id, equals(1));

      // Verify the repository was called exactly once with any Food argument.
      // Times.once equivalent in Mockito is just verify() with no count —
      // it defaults to expecting exactly one call.
      verify(mockRepo.create(any)).called(1);
    });

    // ── Test 17 ──────────────────────────────────────────────────────────────
    // What: failed create → state transitions to AsyncError
    // Why: errors must surface to the UI so the listener can show a snackbar.
    // If the error is swallowed and state stays on AsyncData(null),
    // the user sees nothing and doesn't know the food wasn't saved.
    test('failure sets state to AsyncError', () async {
      // Arrange — mock returns a failure
      final error = Exception('Network error');
      when(mockRepo.create(any)).thenAnswer((_) async => Result.failure(error));

      // Act
      await container.read(foodOperationsProvider.notifier).add(makeFood());

      // Assert
      final state = container.read(foodOperationsProvider);
      expect(state, isA<AsyncError>());
    });

    // ── Test 18 ──────────────────────────────────────────────────────────────
    // What: calling add() while already loading → second call is ignored
    // Why: the user taps LOG FOOD twice quickly. Without this guard,
    // two identical foods are created. The guard `if (state.isLoading) return`
    // in your controller prevents this. This test proves that guard works.
    test('ignores second call while loading', () async {
      // Arrange — mock takes a long time to respond
      when(mockRepo.create(any)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return Result.success(makeFood(id: 1));
      });

      // Act — fire two calls without awaiting the first
      // ignore: unawaited_futures
      container.read(foodOperationsProvider.notifier).add(makeFood());
      // ignore: unawaited_futures
      container.read(foodOperationsProvider.notifier).add(makeFood());

      // Wait for both to settle
      await Future.delayed(const Duration(milliseconds: 200));

      // Assert — repository was only called once despite two add() calls
      verify(mockRepo.create(any)).called(1);
    });

    // ── Test 19 ──────────────────────────────────────────────────────────────
    // What: delete success → state is AsyncData(null)
    // Why: delete doesn't return a food — it returns bool.
    // AsyncData(null) is the correct "operation completed, nothing to return" state.
    // The listener in QuickLogPage checks prev?.isLoading == true before
    // reacting — this test proves state lands correctly for that check.
    test('delete success sets state to AsyncData null', () async {
      when(mockRepo.delete(any)).thenAnswer((_) async => Result.success(true));

      await container.read(foodOperationsProvider.notifier).delete(1);

      final state = container.read(foodOperationsProvider);
      expect(state, isA<AsyncData<Food?>>());
      expect(state.value, isNull);
    });
  });
}
