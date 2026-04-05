import 'package:calinout/core/config/app_config.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl => AppConfig.apiBaseUrl;

  // auth
  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String logout = '/api/v1/auth/logout';
  static const String refreshToken = '/api/v1/auth/refresh';

  // food type
  static const String foodTypesEndPoint = '/api/v1/FoodTypes';

  // food
  static const String foodsEndpoint = '/api/v1/Foods';

  // meal
  static const String mealsEndpoint = '/api/v1/Meals';

  // dailyLog
  static const String dailyLogsEndpoint = '/api/v1/DailyLogs';

  // userProfile
  static const String userProfile = '/api/v1/UserProfile';
}
