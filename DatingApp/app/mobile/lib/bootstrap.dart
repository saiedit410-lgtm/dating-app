import 'dart:async';

import 'package:dating_app/app.dart';
import 'package:dating_app/core/config/env_config.dart';
import 'package:dating_app/core/error/error_handler.dart';
import 'package:dating_app/core/firebase/firebase_bootstrap.dart';
import 'package:dating_app/core/logging/app_logger.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Boots the application.
///
/// Creates the root [ProviderContainer] so that startup code (error handlers,
/// logging) and the widget tree share the exact same provider state, then
/// initializes Firebase and runs the app inside a guarded zone so that no
/// error escapes uncaught.
Future<void> bootstrap() async {
  // A single container shared between bootstrap and the widget tree.
  final container = ProviderContainer();
  final logger = container.read(appLoggerProvider);
  final env = container.read(envConfigProvider);

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      registerGlobalErrorHandlers(logger);
      logger.info('Bootstrapping ${env.appName} [${env.environment.name}]');

      await initializeFirebase(env, logger);

      runApp(
        UncontrolledProviderScope(
          container: container,
          child: const DatingApp(),
        ),
      );
    },
    (error, stackTrace) {
      logger.error('Uncaught zone error', error, stackTrace);
    },
  );
}
