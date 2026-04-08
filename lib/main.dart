import 'dart:async';
import 'package:calinout/calinout.dart';
import 'package:calinout/core/config/app_config.dart';
import 'package:calinout/core/database/hive_service.dart';
import 'package:calinout/core/logger/talker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger_observer.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // use talker here for initialize loggign
  final talkerInstance = TalkerFlutter.init();

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // 2. Safe Initialization
      try {
        // changed to parallel run, add later other initiazation
        final configFuture = AppConfig.load();
        final hiveInitFuture = HiveService.instance.init();
        await Future.wait([configFuture, hiveInitFuture]);

        AppConfig.validate();
      } catch (e) {
        talkerInstance.handle(e);
      }
    },
    (error, stack) {
      talkerInstance.handle(error);
    },
  );

  runApp(
    ProviderScope(
      observers: [
        TalkerRiverpodObserver(
          talker: talkerInstance,
          settings: const TalkerRiverpodLoggerSettings(
            printProviderAdded: false,
            printProviderFailed: true,
            printProviderUpdated: false,
          ),
        ),
      ],
      overrides: [talkerProvider.overrideWithValue(talkerInstance)],
      child: Calinout(),
    ),
  );
}
