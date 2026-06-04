/// The deployment environments the app can run against.
///
/// Selected at build time via `--dart-define=APP_ENV=<name>` and mapped to a
/// Firebase project + configuration in a later milestone. No secrets live here.
enum AppEnvironment {
  dev,
  staging,
  prod;

  /// Resolves an [AppEnvironment] from a raw string, defaulting to [dev] for
  /// any unknown or empty value so a misconfigured build fails safe (never
  /// silently runs as production).
  static AppEnvironment fromName(String name) {
    final normalized = name.trim().toLowerCase();
    return AppEnvironment.values.firstWhere(
      (env) => env.name == normalized,
      orElse: () => AppEnvironment.dev,
    );
  }

  bool get isProduction => this == AppEnvironment.prod;
}
