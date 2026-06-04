import 'package:dating_app/core/config/app_environment.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'env_config.g.dart';

/// Immutable, environment-specific runtime configuration.
///
/// Values are resolved once at startup from compile-time `--dart-define`s so
/// they are tree-shakeable and contain no runtime secrets.
class EnvConfig {
  const EnvConfig({
    required this.environment,
    required this.appName,
    required this.enableVerboseLogging,
    required this.useFirebaseEmulators,
    this.authEmulatorPort = 9099,
    this.firestoreEmulatorPort = 8080,
    this.storageEmulatorPort = 9199,
  });

  final AppEnvironment environment;
  final String appName;
  final bool enableVerboseLogging;

  /// When true, Firebase SDKs connect to the local Emulator Suite instead of
  /// the live project. On by default for non-prod; disable with
  /// `--dart-define=USE_FIREBASE_EMULATORS=false`. Always false in production.
  final bool useFirebaseEmulators;

  /// Emulator ports — must match `firebase.json` in the repo root.
  final int authEmulatorPort;
  final int firestoreEmulatorPort;
  final int storageEmulatorPort;

  /// Resolves configuration from the build environment.
  ///
  /// `--dart-define=APP_ENV=dev|staging|prod` (defaults to `dev`).
  static EnvConfig resolve() {
    const raw = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    const emulatorsFlag = bool.fromEnvironment(
      'USE_FIREBASE_EMULATORS',
      defaultValue: true,
    );
    final environment = AppEnvironment.fromName(raw);
    return EnvConfig(
      environment: environment,
      appName: switch (environment) {
        AppEnvironment.dev => 'Spark (Dev)',
        AppEnvironment.staging => 'Spark (Staging)',
        AppEnvironment.prod => 'Spark',
      },
      enableVerboseLogging: !environment.isProduction,
      // Emulators are never used in production, regardless of the flag.
      useFirebaseEmulators: emulatorsFlag && !environment.isProduction,
    );
  }
}

/// Provides the resolved [EnvConfig] to the rest of the app.
@Riverpod(keepAlive: true)
EnvConfig envConfig(Ref ref) => EnvConfig.resolve();
