/// Base type for all known, handled exceptions thrown by the data layer.
///
/// Data sources/repositories throw these; the presentation layer never sees
/// raw platform exceptions — they are mapped to `Failure`s before reaching UI.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType: $message';
}

/// A failure reading/writing local cache or device storage.
final class CacheException extends AppException {
  const CacheException(super.message, {super.cause, super.stackTrace});
}

/// A network/connectivity or remote-service failure.
final class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause, super.stackTrace});
}

/// An unexpected, unclassified failure (programmer error / unknown state).
final class UnexpectedException extends AppException {
  const UnexpectedException(super.message, {super.cause, super.stackTrace});
}
