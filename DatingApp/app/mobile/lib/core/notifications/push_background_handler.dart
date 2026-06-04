import 'package:firebase_messaging/firebase_messaging.dart';

/// Background/terminated push handler.
///
/// Our Cloud Functions send messages with a `notification` payload, which the
/// Android system displays automatically while the app is backgrounded — so no
/// work is required here for this phase. Must be a top-level function annotated
/// with `@pragma('vm:entry-point')` (runs in its own isolate).
@pragma('vm:entry-point')
Future<void> pushBackgroundHandler(RemoteMessage message) async {
  // Intentionally empty: system tray handles notification-payload messages.
}
