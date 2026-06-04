import 'dart:async';
import 'dart:io' show Platform;

import 'package:dating_app/core/logging/app_logger.dart';
import 'package:dating_app/core/notifications/root_messenger.dart';
import 'package:dating_app/features/notifications/data/device_token_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// Owns FCM permission, token registration/refresh, and foreground display.
///
/// Lives only in the real app (wired in `bootstrap`), so the widget/test tree
/// never instantiates `FirebaseMessaging`.
class NotificationService {
  NotificationService(this._messaging, this._tokens, this._logger);

  final FirebaseMessaging _messaging;
  final DeviceTokenRepository _tokens;
  final AppLogger _logger;

  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<String>? _onTokenRefreshSub;
  String? _uid;

  /// Requests permission and wires foreground + token-refresh listeners.
  Future<void> initialize() async {
    final NotificationSettings settings = await _messaging.requestPermission();
    _logger.info(
      'Notification permission: ${settings.authorizationStatus.name}',
    );
    _onMessageSub = FirebaseMessaging.onMessage.listen(_showInApp);
    _onTokenRefreshSub = _messaging.onTokenRefresh.listen((String token) {
      final String? uid = _uid;
      if (uid != null) unawaited(_save(uid, token));
    });
  }

  /// Registers this device's token for [uid] (call on sign-in).
  Future<void> registerFor(String uid) async {
    _uid = uid;
    try {
      final String? token = await _messaging.getToken();
      if (token != null) await _save(uid, token);
    } catch (error, stack) {
      _logger.warning('Could not register device token', error, stack);
    }
  }

  /// Removes this device's token for the current user (call on sign-out).
  Future<void> unregister() async {
    final String? uid = _uid;
    _uid = null;
    if (uid == null) return;
    try {
      final String? token = await _messaging.getToken();
      if (token != null) await _tokens.deleteToken(uid, token);
    } catch (error, stack) {
      _logger.warning('Could not remove device token', error, stack);
    }
  }

  Future<void> _save(String uid, String token) async {
    try {
      await _tokens.saveToken(uid, token, platform: _platform);
    } catch (error, stack) {
      _logger.warning('Could not save device token', error, stack);
    }
  }

  void _showInApp(RemoteMessage message) {
    final RemoteNotification? n = message.notification;
    if (n == null) return;
    final String text = n.title != null
        ? '${n.title}: ${n.body ?? ''}'
        : (n.body ?? '');
    if (text.trim().isEmpty) return;
    rootScaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  String get _platform => Platform.isIOS ? 'ios' : 'android';

  void dispose() {
    _onMessageSub?.cancel();
    _onTokenRefreshSub?.cancel();
  }
}
