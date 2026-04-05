import 'package:calinout/core/config/routes.dart';
import 'package:calinout/core/logger/talker.dart';
import 'package:calinout/core/presentation/pages/error_page.dart';
import 'package:calinout/core/presentation/pages/splash_page.dart';
import 'package:calinout/core/presentation/scaffold/adaptive_scaffold.dart';
import 'package:calinout/features/auth/presentation/logic/auth_controller.dart';
import 'package:calinout/features/auth/presentation/pages/login_page.dart';
import 'package:calinout/features/auth/presentation/pages/register_page.dart';
import 'package:calinout/features/auth/presentation/pages/welcome_page.dart';
import 'package:calinout/features/food_type_library/domain/entities/food_type.dart';
import 'package:calinout/features/food_type_library/presentation/pages/add_food_type_page.dart';
import 'package:calinout/features/food_type_library/presentation/pages/food_type_page.dart';
import 'package:calinout/features/food_type_library/presentation/pages/update_food_type_page.dart';
import 'package:calinout/features/home_manager/presentation/pages/home_page.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/food.dart';
import 'package:calinout/features/nutrient_logs/domain/entities/meal.dart';
import 'package:calinout/features/nutrient_logs/presentation/pages/add_food_page.dart';
import 'package:calinout/features/nutrient_logs/presentation/pages/add_meal_page.dart';
import 'package:calinout/features/nutrient_logs/presentation/pages/nutrition_log_page.dart';
import 'package:calinout/features/nutrient_logs/presentation/pages/quick_log_page.dart';
import 'package:calinout/features/nutrient_logs/presentation/pages/update_food_page.dart';
import 'package:calinout/features/nutrient_logs/presentation/pages/update_meal_page.dart';
import 'package:calinout/features/user_profile/presentation/pages/profile_page.dart';
import 'package:calinout/features/weight/presentation/pages/add_weight_page.dart';
import 'package:calinout/features/weight/presentation/pages/weight_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

// We define a GlobalKey to access the navigator without context if needed
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>();

class GoRouterNotifier extends ChangeNotifier {
  GoRouterNotifier(Ref ref) {
    ref.listen(authControllerProvider, (_, _) {
      notifyListeners();
    });
  }
}

@riverpod
GoRouter goRouter(Ref ref) {
  final authNotifier = GoRouterNotifier(ref);
  final talkerLog = ref.watch(talkerProvider);

  String? redirect(BuildContext context, GoRouterState routerState) {
    final authStatus = ref.read(authControllerProvider);
    return authStatus.whenOrNull(
      loading: () =>
          (routerState.matchedLocation == Routes.splash) ? null : Routes.splash,

      data: (auth) {
        final currentLocation = routerState.matchedLocation;
        final isAuthenticated = auth == AuthStatus.authenticated;

        if (currentLocation == Routes.splash) {
          return isAuthenticated ? Routes.home : Routes.welcome;
        }
        bool isAuthPage =
            (currentLocation == Routes.login ||
            currentLocation == Routes.register ||
            currentLocation == Routes.welcome);

        if (isAuthenticated && isAuthPage) {
          return Routes.home;
        }

        if (!isAuthenticated && !isAuthPage) {
          return Routes.welcome;
        }
        return null;
      },
    );
    // return Routes.localPageFood;
  }

  return GoRouter(
    initialLocation: Routes.home,
    navigatorKey: _rootNavigatorKey,
    refreshListenable: authNotifier,
    debugLogDiagnostics: true,
    redirect: (context, state) => redirect(context, state),
    errorBuilder: (context, state) {
      talkerLog.error(state.error?.message, state.error);
      return ErrorPage(error: state.error);
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (context, state) => SplashPage()),
      GoRoute(path: Routes.welcome, builder: (context, state) => WelcomePage()),
      GoRoute(path: Routes.login, builder: (context, state) => LoginPage()),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => RegisterPage(),
      ),
      GoRoute(
        path: Routes.addFoodTypePage,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => AddFoodTypePage(),
      ),

      GoRoute(
        path: Routes.updateFoodTypeScreen,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            UpdateFoodTypePage(foodType: state.extra as FoodType),
      ),

      GoRoute(
        path: Routes.addFoodPage,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => AddFoodPage(),
      ),

      GoRoute(
        path: Routes.addMealPage,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => AddMealPage(),
      ),

      GoRoute(
        path: Routes.updateFoodPage,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => UpdateFoodPage(food: state.extra as Food),
      ),

      GoRoute(
        path: Routes.updateMealPage,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => UpdateMealPage(meal: state.extra as Meal),
      ),

      GoRoute(
        path: Routes.quickLogPage,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => QuickLogPage(),
      ),
      GoRoute(
        path: Routes.addWeightPage,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddWeightPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdaptiveScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Dashboard
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          // Branch 1: Food Type
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.foodTypePage,
                builder: (context, state) => const FoodTypePage(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.nutritionLogPage,
                builder: (context, state) => const NutritionLogPage(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.weightPage,
                builder: (context, state) => const WeightPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
