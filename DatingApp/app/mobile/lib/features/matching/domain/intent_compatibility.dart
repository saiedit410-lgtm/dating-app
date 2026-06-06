import 'package:dating_app/features/profile/domain/profile_enums.dart';

/// Single source of truth for [DatingIntent] compatibility.
///
/// Both the hard filter (in [MatchFilters]) and the soft `f_intent`
/// term in the scorer read from this function. Adjusting the
/// matrix here adjusts both surfaces — no risk of drift.
///
/// Symmetric. Returns `1.0` for identical intents, `0.2` for the
/// least-compatible pair (long-term × friendship), and a `0.4` floor
/// for any other combination.
double intentCompatibility(DatingIntent a, DatingIntent b) {
  if (a == b) return 1.0;
  if (a == DatingIntent.notSure || b == DatingIntent.notSure) return 0.6;
  if ((a == DatingIntent.longTerm && b == DatingIntent.casual) ||
      (a == DatingIntent.casual && b == DatingIntent.longTerm)) {
    return 0.4;
  }
  if ((a == DatingIntent.longTerm && b == DatingIntent.friendship) ||
      (a == DatingIntent.friendship && b == DatingIntent.longTerm)) {
    return 0.2;
  }
  if ((a == DatingIntent.casual && b == DatingIntent.friendship) ||
      (a == DatingIntent.friendship && b == DatingIntent.casual)) {
    return 0.5;
  }
  return 0.6;
}
