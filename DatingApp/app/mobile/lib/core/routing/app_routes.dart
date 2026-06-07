/// Centralised route definitions (path + name) for the whole app.
///
/// Keeping paths and names in one enum avoids magic strings scattered across
/// the codebase and makes named navigation refactor-safe.
enum AppRoute {
  splash('/', 'splash'),
  login('/login', 'login'),
  otp('/otp', 'otp'),
  onboarding('/onboarding', 'onboarding'),
  home('/home', 'home'),
  photos('/photos', 'photos'),
  discovery('/discovery', 'discovery'),
  profileDetail('/profile/:uid', 'profileDetail'),
  requests('/requests', 'requests'),
  connections('/connections', 'connections'),
  chats('/chats', 'chats'),
  chat('/chat/:uid', 'chat'),
  verification('/verification', 'verification'),
  likesSent('/likes/sent', 'likesSent'),
  likesReceived('/likes/received', 'likesReceived'),
  recentVisitors('/visitors', 'recentVisitors'),
  admin('/admin', 'admin'),
  adminVerifications('/admin/verifications', 'adminVerifications'),
  adminVerificationDetail('/admin/verifications/:uid', 'adminVerificationDetail'),
  adminReports('/admin/reports', 'adminReports'),
  adminReportDetail('/admin/reports/:reportId', 'adminReportDetail'),
  adminUserDetail('/admin/users/:uid', 'adminUserDetail'),
  adminAudit('/admin/audit', 'adminAudit');

  const AppRoute(this.path, this.routeName);

  /// The URL path used by GoRouter (e.g. `/login`).
  final String path;

  /// The stable name used for `goNamed`/`pushNamed` navigation.
  final String routeName;
}
