import 'dart:developer' as developer;

import 'package:dating_app/core/config/env_config.dart';
import 'package:dating_app/core/constants/app_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_logger.g.dart';

/// Severity levels, ordered from least to most severe.
enum LogLevel { debug, info, warning, error }

/// A lightweight structured logger built on `dart:developer`.
///
/// Uses the platform logging channel (visible in the IDE / `flutter logs`)
/// rather than `print`, and filters by [minLevel]. In a later milestone this
/// same surface forwards `error`/`warning` to Crashlytics.
class AppLogger {
  const AppLogger({
    this.minLevel = LogLevel.debug,
    this.name = AppConstants.appTechName,
  });

  final LogLevel minLevel;
  final String name;

  void debug(String message) => _log(LogLevel.debug, message);

  void info(String message) => _log(LogLevel.info, message);

  void warning(String message, [Object? error, StackTrace? stackTrace]) =>
      _log(LogLevel.warning, message, error, stackTrace);

  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _log(LogLevel.error, message, error, stackTrace);

  void _log(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (level.index < minLevel.index) return;
    developer.log(
      message,
      name: '$name.${level.name}',
      level: _severity(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  int _severity(LogLevel level) => switch (level) {
    LogLevel.debug => 500,
    LogLevel.info => 800,
    LogLevel.warning => 900,
    LogLevel.error => 1000,
  };
}

/// Provides a process-wide [AppLogger] whose verbosity follows the environment.
@Riverpod(keepAlive: true)
AppLogger appLogger(Ref ref) {
  final env = ref.watch(envConfigProvider);
  return AppLogger(
    minLevel: env.enableVerboseLogging ? LogLevel.debug : LogLevel.warning,
  );
}
