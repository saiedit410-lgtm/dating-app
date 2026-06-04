/// Typed, user-presentable authentication failures.
///
/// The data layer maps `FirebaseAuthException` codes onto these so the UI can
/// render friendly, blame-free messages (see docs/DesignSystem.md error states)
/// without ever seeing a raw platform exception.
enum AuthFailure {
  invalidPhoneNumber,
  invalidVerificationCode,
  sessionExpired,
  tooManyRequests,
  network,
  quotaExceeded,
  unknown;

  /// A short, user-facing message for each failure.
  String get message => switch (this) {
    AuthFailure.invalidPhoneNumber =>
      'That phone number looks invalid. Please check and try again.',
    AuthFailure.invalidVerificationCode =>
      'That code is incorrect. Please re-enter it.',
    AuthFailure.sessionExpired =>
      'The code expired. Please request a new one.',
    AuthFailure.tooManyRequests =>
      'Too many attempts. Please wait a little while and try again.',
    AuthFailure.network =>
      'Network problem. Check your connection and try again.',
    AuthFailure.quotaExceeded =>
      'SMS limit reached for now. Please try again later.',
    AuthFailure.unknown => 'Something went wrong. Please try again.',
  };
}

/// Thrown by the auth repository for known, handled failures.
class AuthException implements Exception {
  const AuthException(this.failure, {this.cause});

  final AuthFailure failure;
  final Object? cause;

  String get message => failure.message;

  @override
  String toString() => 'AuthException(${failure.name})';
}
