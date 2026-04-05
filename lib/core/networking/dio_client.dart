import 'dart:io';
import 'package:calinout/core/config/app_config.dart';
import 'package:calinout/core/logger/talker.dart';
import 'package:calinout/core/networking/auth_interceptor.dart';
import 'package:calinout/features/auth/data/providers/auth_providers.dart';
import 'package:calinout/features/auth/presentation/logic/auth_controller.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';

part 'dio_client.g.dart';

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final baseOptions = BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  );

  final dio = Dio(baseOptions);

  if (kDebugMode) {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );
  }

  final talker = ref.watch(talkerProvider);
  final authStorage = ref.watch(tokenStorageProvider);

  dio.interceptors.add(
    TalkerDioLogger(
      talker: talker,
      settings: const TalkerDioLoggerSettings(
        printRequestData: false,
        printResponseData: false,
        printResponseMessage: false,
      ),
    ),
  );

  dio.interceptors.add(
    AuthInterceptor(
      storage: authStorage,
      baseUrl: AppConfig.apiBaseUrl,
      onTokensRefreshed: (authResponse) => authStorage.saveTokens(
        authResponse.accessToken,
        authResponse.accessTokenExpiresAt,
        authResponse.refreshToken,
      ),
      isDebug: kDebugMode,

      onRefreshFailed: () => ref.read(authControllerProvider.notifier).logout(),
    ),
  );

  return dio;
}
