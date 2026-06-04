import 'dart:async';

import 'package:dating_app/app.dart';
import 'package:dating_app/core/config/env_config.dart';
import 'package:dating_app/core/error/error_handler.dart';
import 'package:dating_app/core/firebase/firebase_bootstrap.dart';
import 'package:dating_app/core/logging/app_logger.dart';
import 'package:dating_app/core/notifications/push_background_handler.dart';
import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/notifications/application/notification_providers.dart';
import 'package:dating_app/features/notifications/application/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Boots the application.
///
/// Creates the root [ProviderContainer] so that startup code (error handlers,
/// logging, push notifications) and the widget tree share the exact same
/// provider state, then initializes Firebase and runs the app inside a guarded
/// zone so that no error escapes uncaught.
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
      _setupPushNotifications(container);

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

/// Registers the background handler and ties device-token registration to the
/// auth state (register on sign-in, remove on sign-out). Fire-and-forget so it
/// never blocks first frame.
void _setupPushNotifications(ProviderContainer container) {
  FirebaseMessaging.onBackgroundMessage(pushBackgroundHandler);
  final NotificationService notifications = container.read(
    notificationServiceProvider,
  );
  unawaited(notifications.initialize());
  container.listen(authStateChangesProvider, (_, next) {
    final String? uid = next.value?.uid;
    if (uid != null) {
      unawaited(notifications.registerFor(uid));
    } else {
      unawaited(notifications.unregister());
    }
  }, fireImmediately: true);
}
