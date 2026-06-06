import 'package:dating_app/features/discovery/domain/public_profile.dart';
import 'package:dating_app/features/matching/domain/intent_compatibility.dart';
import 'package:dating_app/features/matching/domain/match_filter_outcome.dart';
import 'package:dating_app/features/matching/domain/match_filters.dart';
import 'package:dating_app/features/matching/domain/match_preferences.dart';
import 'package:dating_app/features/matching/domain/match_weights.dart';
import 'package:dating_app/features/matching/domain/scored_profile.dart';
import 'package:dating_app/features/matching/domain/user_interests.dart';
import 'package:dating_app/features/profile/domain/profile_enums.dart';

/// Inputs the scorer needs about the **viewer** (the signed-in user)
/// beyond what fits in [MatchPreferences]. Most fields are nullable
/// so the scorer degrades gracefully when the viewer's profile is
/// partial.
class ViewerContext {
  const ViewerContext({
    required this.uid,
    this.datingIntent,
    this.interests = const <String>[],
  });

  final String uid;
  final DatingIntent? datingIntent;
  final List<String> interests;
}

/// Pure-Dart matching scorer. Single source of truth for how a
/// `(viewer, subject)` pair becomes a [ScoredProfile]. Used by
/// both client-side and (future) server-side ranking — same code,
/// same output.
///
/// The scorer is intentionally stateless: pass a [MatchWeights] on
/// every call so the same instance can drive All and Nearby tabs
/// with different weight vectors.
class MatchScorer {
  const MatchScorer({this.filters = const MatchFilters()});

  final MatchFilters filters;

  /// Scores one `(viewer, subject)` pair. Returns `null` if any hard
  /// filter excludes the subject. Distance is only consulted when
  /// `weights.wDist > 0` (Nearby feed).
  ScoredProfile? evaluate({
    required ViewerContext viewer,
    required PublicProfile subject,
    required MatchPreferences viewerPrefs,
    required Set<String> blockedUids,
    required MatchWeights weights,
    double? subjectDistanceKm,
  }) {
    final outcome = filters.apply(
      viewerUid: viewer.uid,
      subject: subject,
      blockedUids: blockedUids,
      viewerPrefs: viewerPrefs,
      viewerIntent: viewer.datingIntent,
    );
    if (outcome is Exclude) return null;

    final Map<String, double> terms = <String, double>{
      'interest': _fInterest(viewer.interests, subject.interests),
      'intent': _fIntent(viewer.datingIntent, subject.datingIntent),
      'verify': subject.isVerified ? 1.0 : 0.0,
    };
    if (weights.wDist > 0) {
      terms['dist'] = _fDist(subjectDistanceKm);
    }

    final double composite = _weightedSum(terms, weights);
    return ScoredProfile(
      profile: subject,
      score: composite,
      terms: terms,
      distanceKm: subjectDistanceKm,
    );
  }

  // ---------- term functions ----------

  /// Piecewise-linear with a 2 km nearBand plateau. Returns 0.5
  /// (neutral) when the subject has no geohash.
  static double _fDist(double? distanceKm) {
    if (distanceKm == null) return 0.5;
    const double nearBand = 2.0;
    const double cap = 50.0;
    if (distanceKm <= nearBand) return 1.0;
    if (distanceKm >= cap) return 0.0;
    final double t = (distanceKm - nearBand) / (cap - nearBand);
    return (1.0 - t).clamp(0.0, 1.0);
  }

  static double _fInterest(
    List<String> viewerInterests,
    List<String> subjectInterests,
  ) {
    return UserInterests.fromStorage(viewerInterests)
        .jaccardWith(UserInterests.fromStorage(subjectInterests));
  }

  static double _fIntent(
    DatingIntent? viewerIntent,
    DatingIntent? subjectIntent,
  ) {
    if (viewerIntent == null || subjectIntent == null) return 0.5;
    return intentCompatibility(viewerIntent, subjectIntent);
  }

  static double _weightedSum(Map<String, double> terms, MatchWeights w) {
    double s = 0;
    s += (terms['dist'] ?? 0) * w.wDist;
    s += (terms['interest'] ?? 0) * w.wInterest;
    s += (terms['intent'] ?? 0) * w.wIntent;
    s += (terms['verify'] ?? 0) * w.wVerify;
    return (s * 100).clamp(0.0, 100.0);
  }
}
