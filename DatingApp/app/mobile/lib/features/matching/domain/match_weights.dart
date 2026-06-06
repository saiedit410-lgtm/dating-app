/// Weights for the four soft-score terms used by [MatchScorer].
///
/// Sum of all weights must be `1.0` (within epsilon). Two
/// tab-scoped presets — [forAll] and [forNearby] — encode the
/// different ranking intent. The weight vector is the **single
/// tunable surface** of the matching engine: it can be flipped from
/// Remote Config without a release.
class MatchWeights {
  const MatchWeights({
    required this.wDist,
    required this.wInterest,
    required this.wIntent,
    required this.wVerify,
  });

  /// Default weights for the "All Discovery" tab. Distance is
  /// explicitly zero — we never tell a worldwide user a far-away
  /// person is a poor match.
  static const MatchWeights forAll = MatchWeights(
    wDist: 0.00,
    wInterest: 0.40,
    wIntent: 0.35,
    wVerify: 0.25,
  );

  /// Default weights for the "Nearby" tab. Distance is dominant but
  /// compatibility terms still apply.
  static const MatchWeights forNearby = MatchWeights(
    wDist: 0.30,
    wInterest: 0.30,
    wIntent: 0.25,
    wVerify: 0.15,
  );

  final double wDist;
  final double wInterest;
  final double wIntent;
  final double wVerify;

  /// Sum of all weights. Used to assert the config is valid.
  double get sum => wDist + wInterest + wIntent + wVerify;

  /// True when sum is within 1e-6 of 1.0.
  bool get isValid => (sum - 1.0).abs() < 1e-6;

  /// Read from a `String -> num` map (e.g. Remote Config or
  /// `--dart-define`). Missing keys fall back to [fallback] values.
  /// Per-term values are clamped to `[0, 1]`. The returned vector is
  /// **not** renormalized — the caller is expected to pass a
  /// complete vector.
  static MatchWeights fromMap(
    Map<String, Object?> raw, {
    MatchWeights fallback = forAll,
  }) {
    double read(String key, double defaultValue) {
      final Object? v = raw[key];
      if (v is num) return v.toDouble().clamp(0.0, 1.0);
      if (v is String) {
        return double.tryParse(v)?.clamp(0.0, 1.0) ?? defaultValue;
      }
      return defaultValue;
    }

    return MatchWeights(
      wDist: read('wDist', fallback.wDist),
      wInterest: read('wInterest', fallback.wInterest),
      wIntent: read('wIntent', fallback.wIntent),
      wVerify: read('wVerify', fallback.wVerify),
    );
  }
}
