/// The outcome of one hard filter in the compatibility chain.
///
/// Filters fail-closed: a single `exclude` removes the subject from the
/// candidate set. The reason code is for analytics only — never rendered to
/// the user.
sealed class MatchFilterOutcome {
  const MatchFilterOutcome();
}

class Keep extends MatchFilterOutcome {
  const Keep();
}

/// Exclude with a stable reason code for telemetry.
class Exclude extends MatchFilterOutcome {
  const Exclude(this.reason);

  /// Stable, machine-readable reason (e.g. `'self'`, `'blocked'`,
  /// `'age_range'`). Never shown to users.
  final String reason;
}
