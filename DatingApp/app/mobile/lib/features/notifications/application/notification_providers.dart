import 'package:dating_app/core/firebase/firebase_providers.dart';
import 'package:dating_app/core/logging/app_logger.dart';
import 'package:dating_app/features/notifications/application/notification_service.dart';
import 'package:dating_app/features/notifications/data/device_token_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_providers.g.dart';

@Riverpod(keepAlive: true)
DeviceTokenRepository deviceTokenRepository(Ref ref) =>
    DeviceTokenRepository(ref.watch(firebaseFirestoreProvider));

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) => NotificationService(
  FirebaseMessaging.instance,
  ref.watch(deviceTokenRepositoryProvider),
  ref.watch(appLoggerProvider),
);
