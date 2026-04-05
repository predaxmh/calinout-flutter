import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'dev';

  static bool get enableLogging =>
      dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true';

  static bool get isDevelopment => appEnv == 'dev';
  static bool get isProduction => appEnv == 'prod';

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static void validate() {
    if (apiBaseUrl.isEmpty) {
      throw Exception('API_BASE_URL not configured');
    }
  }
}
