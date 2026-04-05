import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:talker_flutter/talker_flutter.dart';

class TokenStorage {
  final Talker _talkerLog;

  TokenStorage(this._talkerLog);

  // 🟢 1. Configure Android Security
  static AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
    // Ensures keys are not backed up to Google Drive (Security Best Practice)
    sharedPreferencesName: 'calinout_secure_prefs',
    resetOnError: true,
  );

  // 🟢 2. Configure iOS Security
  static IOSOptions _getIOSOptions() => const IOSOptions(
    // 'first_unlock': Accessible in background after first unlock (Good for sync)
    accessibility: KeychainAccessibility.first_unlock,
  );

  // 🟢 3. Initialize with Options
  final _secure = FlutterSecureStorage(
    aOptions: _getAndroidOptions(),
    iOptions: _getIOSOptions(),
  );

  static const String _accessKey = 'access_token';
  static const String _refreshKey = 'refresh_token';
  static const String _expiresAt = 'expires_at';

  Future<void> saveTokens(
    String accessToken,
    DateTime expiresAt,
    String refreshToken,
  ) async {
    try {
      await Future.wait([
        _secure.write(key: _accessKey, value: accessToken),
        _secure.write(key: _refreshKey, value: refreshToken),
        _secure.write(key: _expiresAt, value: expiresAt.toIso8601String()),
      ]);
      _talkerLog.debug('🔐 Storage: Tokens saved securely');
    } catch (e, stack) {
      _talkerLog.error('❌ Storage: Failed to save tokens', e, stack);
      rethrow; // Critical error, let the repo handle it
    }
  }

  Future<String?> readAccessToken() async {
    final token = await _secure.read(key: _accessKey);
    return token;
  }

  Future<String?> readRefreshToken() async {
    final token = await _secure.read(key: _refreshKey);
    return token;
  }

  Future<bool> hasRefreshToken() async {
    return await _secure.containsKey(key: _refreshKey);
  }

  Future<void> deleleAccessToken() async {
    try {
      await Future.wait([_secure.delete(key: _accessKey)]);
      _talkerLog.info('🗑️ Storage: Token cleared');
    } catch (e) {
      _talkerLog.warning('⚠️ Storage: Failed to clear tokens completely: $e');
    }
  }

  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _secure.delete(key: _accessKey),
        _secure.delete(key: _refreshKey),
        _secure.delete(key: _expiresAt),
      ]);
      _talkerLog.info('🗑️ Storage: Tokens cleared');
    } catch (e) {
      _talkerLog.warning('⚠️ Storage: Failed to clear tokens completely: $e');
    }
  }

  Future<DateTime?> readExpiration() async {
    final dateStr = await _secure.read(key: _expiresAt);
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }
}
