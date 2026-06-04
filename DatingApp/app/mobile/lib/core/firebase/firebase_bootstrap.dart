import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/core/config/env_config.dart';
import 'package:dating_app/core/logging/app_logger.dart';
import 'package:dating_app/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Initializes Firebase for the current platform and, in development, points
/// the SDKs at the local Emulator Suite.
///
/// Called once from [bootstrap] before `runApp`. No authentication or data
/// logic lives here — only connection wiring.
Future<void> initializeFirebase(EnvConfig env, AppLogger logger) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (env.useFirebaseEmulators) {
    final host = _emulatorHost;
    logger.info('Firebase: connecting to Emulator Suite at $host');
    await FirebaseAuth.instance.useAuthEmulator(host, env.authEmulatorPort);
    FirebaseFirestore.instance.useFirestoreEmulator(
      host,
      env.firestoreEmulatorPort,
    );
    await FirebaseStorage.instance.useStorageEmulator(
      host,
      env.storageEmulatorPort,
    );
  } else {
    logger.info('Firebase: using live project (${env.environment.name})');
  }
}

/// The Android *emulator* reaches the host machine via the special alias
/// `10.0.2.2`; every other target uses `localhost`. (A physical device would
/// instead use the host's LAN IP — handled when we add device testing.)
String get _emulatorHost =>
    defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : 'localhost';
