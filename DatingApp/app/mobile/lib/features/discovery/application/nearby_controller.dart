import 'package:dating_app/core/config/env_config.dart';
import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/discovery/application/discovery_providers.dart';
import 'package:dating_app/features/discovery/application/location_controller.dart';
import 'package:dating_app/features/discovery/domain/nearby_radius.dart';
import 'package:dating_app/features/matching/application/matching_providers.dart';
import 'package:dating_app/features/matching/domain/feed_status.dart';
import 'package:dating_app/features/matching/domain/match_preferences.dart';
import 'package:dating_app/features/matching/domain/match_scorer.dart';
import 'package:dating_app/features/matching/domain/match_weights.dart';
import 'package:dating_app/features/matching/domain/ranked_feed_state.dart';
import 'package:dating_app/features/matching/domain/scored_profile.dart';
import 'package:dating_app/features/safety/application/safety_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nearby_controller.g.dart';

/// The single Nearby feed controller.
///
/// Phase 2.2: replaces both the legacy `NearbyController` and the
/// `RankedNearbyController` with a single controller that emits
/// [RankedFeedState] over [ScoredProfile]. When the
/// [matchingEngineEnabled] feature flag is off, scoring is skipped
/// and distance is the only sort key (legacy behavior).
@riverpod
class NearbyController extends _$NearbyController {
  static const int _pageSize = 20;

  @override
  RankedFeedState<ScoredProfile> build() {
    return const RankedFeedState<ScoredProfile>();
  }

  Future<void> loadInitial() async {
    if (state.status != FeedStatus.initial) return;
    await _fetch(reset: true);
  }

  Future<void> refresh() => _fetch(reset: true);

  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.status == FeedStatus.loading ||
        state.items.isEmpty) {
      return;
    }
    await _fetch(reset: false);
  }

  Future<void> setRadius(NearbyRadius radius) async {
    if (ref.read(nearbyRadiusControllerProvider) == radius) return;
    ref.read(nearbyRadiusControllerProvider.notifier).set(radius);
    await _fetch(reset: true);
  }

  Future<void> _fetch({required bool reset}) async {
    final locState = ref.read(locationControllerProvider);
    final origin = locState.location;
    if (origin == null) {
      // No position yet — the UI is responsible for prompting the
      // user via `LocationController`. Sit in `initial`.
      return;
    }

    final NearbyRadius radius = ref.read(nearbyRadiusControllerProvider);
    final ViewerContext viewer = ref.read(viewerContextProvider);
    final bool matchingOn =
        ref.read(envConfigProvider).matchingEngineEnabled;
    final MatchScorer scorer = ref.read(matchScorerProvider);
    final MatchWeights weights = MatchWeights.forNearby;
    final String? myUid = ref.read(authStateChangesProvider).value?.uid;
    final Set<String> blocked =
        ref.read(blockedUidsProvider).value ?? const <String>{};
    final MatchPreferences viewerPrefs =
        ref.read(currentMatchPreferencesProvider).value ??
            MatchPreferences.defaults(null);

    state = state.copyWith(
      status: FeedStatus.loading,
      items: reset ? <ScoredProfile>[] : null,
      hasMore: reset ? true : null,
      cursor: reset ? null : state.cursor,
      clearError: true,
    );

    try {
      final page = await ref.read(nearbySearchRepositoryProvider).fetchPage(
            originLat: origin.latitude,
            originLng: origin.longitude,
            radius: radius,
            cursor: reset ? null : state.cursor,
            limit: _pageSize,
          );
      final List<ScoredProfile> filtered = <ScoredProfile>[];
      for (final p in page.profiles) {
        if (p.profile.uid == myUid) continue;
        if (blocked.contains(p.profile.uid)) continue;
        if (!matchingOn) {
          filtered.add(ScoredProfile(
            profile: p.profile,
            score: 0,
            terms: const <String, double>{},
            distanceKm: p.distanceKm,
          ));
          continue;
        }
        final ScoredProfile? scored = scorer.evaluate(
          viewer: viewer,
          subject: p.profile,
          viewerPrefs: viewerPrefs,
          blockedUids: blocked,
          weights: weights,
          subjectDistanceKm: p.distanceKm,
        );
        if (scored == null) continue;
        filtered.add(scored);
      }
      if (matchingOn) {
        filtered.sort((ScoredProfile a, ScoredProfile b) {
          final int c = b.score.compareTo(a.score);
          if (c != 0) return c;
          return a.profile.uid.compareTo(b.profile.uid);
        });
      }

      final List<ScoredProfile> merged = reset
          ? filtered
          : <ScoredProfile>[...state.items, ...filtered];

      state = RankedFeedState<ScoredProfile>(
        items: _dedupe(merged),
        status: FeedStatus.loaded,
        hasMore: page.hasMore,
        cursor: page.nextCursor,
      );
    } catch (_) {
      state = state.copyWith(
        status: FeedStatus.error,
        errorMessage: 'Could not load nearby people. Please try again.',
      );
    }
  }

  List<ScoredProfile> _dedupe(List<ScoredProfile> profiles) {
    final Set<String> seen = <String>{};
    return profiles
        .where((ScoredProfile p) => seen.add(p.profile.uid))
        .toList(growable: false);
  }
}

/// The active radius chip on the nearby tab. Lives outside the
/// controller so [setRadius] can be a pure read of the next
/// value, and so the UI can `ref.watch` it without owning it.
@Riverpod(keepAlive: true)
class NearbyRadiusController extends _$NearbyRadiusController {
  @override
  NearbyRadius build() => NearbyRadius.ten;

  // ignore: use_setters_to_change_properties
  void set(NearbyRadius value) => state = value;
}
