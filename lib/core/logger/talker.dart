import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_flutter/talker_flutter.dart';

part 'talker.g.dart';

@Riverpod(keepAlive: true)
Talker talker(Ref ref) {
  return TalkerFlutter.init(
    settings: TalkerSettings(
      // CRITICAL: Disable console printing in release mode for performance
      useConsoleLogs: !kReleaseMode,

      // We keep history even in release so if a crash happens,
      // we can extract the last 50 logs to see what the user did.
      useHistory: true,
      maxHistoryItems: 60,
    ),
    logger: TalkerLogger(
      settings: TalkerLoggerSettings(
        // In release, we only care about errors/warnings.
        // In debug, we want to see everything (verbose).
        level: kReleaseMode ? LogLevel.error : LogLevel.debug,
      ),
    ),
  );
}
