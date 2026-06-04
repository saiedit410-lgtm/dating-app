/// Base type for failures surfaced to the presentation layer.
///
/// Repositories return `Result`/`Either`-style values carrying a [Failure]
/// instead of throwing, so the UI can render a typed, user-friendly state
/// (see the error-state patterns in `docs/DesignSystem.md`).
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Local cache/storage failure.
final class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Network/connectivity failure.
final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Unexpected/unclassified failure.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
