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
  });

  final AppEnvironment environment;
  final String appName;
  final bool enableVerboseLogging;

  /// Resolves configuration from the build environment.
  ///
  /// `--dart-define=APP_ENV=dev|staging|prod` (defaults to `dev`).
  static EnvConfig resolve() {
    const raw = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    final environment = AppEnvironment.fromName(raw);
    return EnvConfig(
      environment: environment,
      appName: switch (environment) {
        AppEnvironment.dev => 'Spark (Dev)',
        AppEnvironment.staging => 'Spark (Staging)',
        AppEnvironment.prod => 'Spark',
      },
      enableVerboseLogging: !environment.isProduction,
    );
  }
}

/// Provides the resolved [EnvConfig] to the rest of the app.
@Riverpod(keepAlive: true)
EnvConfig envConfig(Ref ref) => EnvConfig.resolve();
