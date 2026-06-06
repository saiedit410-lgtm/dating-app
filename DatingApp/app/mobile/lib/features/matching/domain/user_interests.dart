/// A normalized list of user interests used by the matching scorer.
///
/// Reads from a Firestore-shaped list always go through
/// [UserInterests.fromStorage] so the scorer never sees malformed
/// data (uppercase, trailing whitespace, duplicates, oversized).
class UserInterests {
  const UserInterests._(this.values);

  /// Maximum entries per user. Caps the Jaccard denominator and the
  /// size of the public `interests` array on the user doc.
  static const int maxEntries = 12;

  /// Empty list — no signal, not penalized.
  static const UserInterests empty = UserInterests._(<String>[]);

  /// Always lowercase, trimmed, deduped, capped to [maxEntries].
  final List<String> values;

  /// Tolerant read: drops bad entries rather than throwing.
  factory UserInterests.fromStorage(Object? raw) {
    if (raw is! List) return UserInterests.empty;
    final Set<String> seen = <String>{};
    for (final Object? v in raw) {
      if (v is! String) continue;
      final String n = v.trim().toLowerCase();
      if (n.isEmpty) continue;
      seen.add(n);
      if (seen.length >= maxEntries) break;
    }
    return UserInterests._(seen.toList(growable: false));
  }

  /// Jaccard overlap with [other] in `[0, 1]`, with a soft
  /// list-size penalty so a 12-vs-12 profile can't farm 1.0.
  double jaccardWith(UserInterests other) {
    if (values.isEmpty && other.values.isEmpty) return 0.0;
    final Set<String> a = values.toSet();
    final Set<String> b = other.values.toSet();
    final int inter = a.intersection(b).length;
    final int union = a.union(b).length;
    if (union == 0) return 0.0;
    final double j = inter / union;
    final double avgSize = (a.length + b.length) / 2.0;
    final double sizePenalty =
        0.5 + 0.5 * (1 - (avgSize / maxEntries).clamp(0.0, 1.0));
    return (j * sizePenalty).clamp(0.0, 1.0);
  }

  int get length => values.length;
  bool get isEmpty => values.isEmpty;
}
