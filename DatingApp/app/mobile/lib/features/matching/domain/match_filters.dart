import 'package:dating_app/features/discovery/domain/public_profile.dart';
import 'package:dating_app/features/matching/domain/intent_compatibility.dart';
import 'package:dating_app/features/matching/domain/match_filter_outcome.dart';
import 'package:dating_app/features/matching/domain/match_preferences.dart';
import 'package:dating_app/features/profile/domain/profile_enums.dart';

/// Hard filter chain — fail-closed, cheapest-first.
///
/// Phase 2.2 ships **four** filters. The richer mutual-age,
/// mutual-gender, intent-strict, and distance filters from the
/// design doc are deferred to 2.2.1 (they belong with the
/// server-side ranking materialization).
class MatchFilters {
  const MatchFilters();

  /// Runs the hard-filter chain. Returns the first exclusion, or
  /// [Keep] if all pass.
  MatchFilterOutcome apply({
    required String viewerUid,
    required PublicProfile subject,
    required Set<String> blockedUids,
    required MatchPreferences viewerPrefs,
    DatingIntent? viewerIntent,
  }) {
    // 1. Self
    if (subject.uid == viewerUid) return const Exclude('self');

    // 2. Blocked (either direction) — caller passes the merged set.
    if (blockedUids.contains(subject.uid)) return const Exclude('blocked');

    // 3. Onboarding complete — PublicProfile doesn't carry an
    //    explicit flag, but the feed only surfaces users with a
    //    name + age. Both signals missing collapse to
    //    `incomplete_profile`. (The Firestore query also gates on
    //    `onboardingComplete == true` and `accountStatus == 'active'`,
    //    so a subject reaching the client is, in practice, active.)
    if (subject.displayName == null || subject.displayName!.isEmpty) {
      return const Exclude('incomplete_profile');
    }
    if (subject.age == null) return const Exclude('incomplete_profile');

    // 4. Intent-strict (opt-in) — falls back to the matrix floor.
    if (viewerPrefs.requireIntentMatch &&
        subject.datingIntent != null &&
        viewerIntent != null &&
        intentCompatibility(viewerIntent, subject.datingIntent!) <
            viewerPrefs.intentMatrixFloor) {
      return const Exclude('intent_mismatch');
    }

    return const Keep();
  }
}
