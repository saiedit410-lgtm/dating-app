import 'package:dating_app/features/discovery/domain/public_profile.dart';

/// A [PublicProfile] enriched with its matching score and per-term
/// contribution map. Distance is `null` when the subject has no
/// public geohash (e.g. they never granted location).
class ScoredProfile {
  const ScoredProfile({
    required this.profile,
    required this.score,
    required this.terms,
    this.distanceKm,
  });

  final PublicProfile profile;

  /// Composite score in `[0, 100]`.
  final double score;

  /// Per-term `[0, 1]` contribution used to build the composite.
  /// Stable term keys: `'dist'`, `'interest'`, `'intent'`,
  /// `'verify'`. The UI uses this to render the "Why these
  /// results?" breakdown.
  final Map<String, double> terms;

  /// Great-circle distance in km to the viewer's current position,
  /// when both sides have location data. Null otherwise.
  final double? distanceKm;

  /// Short label for the UI, e.g. "92%". Rounded.
  int get scorePercent => score.round();

  /// Returns the top N user-facing reason seeds, in descending
  /// term-value order. Returns an empty list when no term has a
  /// non-zero contribution.
  List<String> topReasons({int max = 3}) {
    final List<MapEntry<String, double>> ranked = terms.entries.toList()
      ..sort((MapEntry<String, double> a, MapEntry<String, double> b) =>
          b.value.compareTo(a.value));
    final List<String> out = <String>[];
    for (final MapEntry<String, double> e in ranked) {
      if (out.length >= max) break;
      final String? seed = _reasonFor(e.key, e.value);
      if (seed != null) out.add(seed);
    }
    return out;
  }

  static String? _reasonFor(String term, double value) {
    if (value <= 0) return null;
    switch (term) {
      case 'dist':
        if (value >= 0.95) return 'Very close by';
        if (value >= 0.7) return 'Nearby';
        return null;
      case 'interest':
        if (value >= 0.7) return 'Lots in common';
        if (value >= 0.4) return 'Some shared interests';
        return null;
      case 'intent':
        return 'Looking for the same thing';
      case 'verify':
        return 'Verified profile';
    }
    return null;
  }
}
