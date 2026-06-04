/// Centralised route definitions (path + name) for the whole app.
///
/// Keeping paths and names in one enum avoids magic strings scattered across
/// the codebase and makes named navigation refactor-safe.
enum AppRoute {
  splash('/', 'splash');

  const AppRoute(this.path, this.routeName);

  /// The URL path used by GoRouter (e.g. `/`).
  final String path;

  /// The stable name used for `goNamed`/`pushNamed` navigation.
  final String routeName;
}
