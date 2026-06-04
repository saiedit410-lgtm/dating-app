import 'package:dating_app/core/logging/app_logger.dart';
import 'package:flutter/foundation.dart';

/// Installs process-wide error handlers that route every uncaught error
/// through the [AppLogger].
///
/// Covers the two framework-level sinks:
///  * [FlutterError.onError] — errors raised within the Flutter framework.
///  * [PlatformDispatcher.instance.onError] — errors in the wider Dart runtime.
///
/// In a later milestone these handlers also forward to Crashlytics.
void registerGlobalErrorHandlers(AppLogger logger) {
  FlutterError.onError = (FlutterErrorDetails details) {
    logger.error(
      'FlutterError: ${details.exceptionAsString()}',
      details.exception,
      details.stack,
    );
    // Still present the error in debug builds for visibility.
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
    logger.error('Uncaught platform error', error, stackTrace);
    return true; // Marks the error as handled.
  };
}
