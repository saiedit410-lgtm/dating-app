import 'package:dating_app/core/config/env_config.dart';
import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/discovery/application/discovery_filters_controller.dart';
import 'package:dating_app/features/discovery/application/discovery_providers.dart';
import 'package:dating_app/features/discovery/domain/discovery_filters.dart';
import 'package:dating_app/features/discovery/domain/public_profile.dart';
import 'package:dating_app/features/matching/application/matching_providers.dart';
import 'package:dating_app/features/matching/domain/feed_status.dart';
import 'package:dating_app/features/matching/domain/match_preferences.dart';
import 'package:dating_app/features/matching/domain/match_scorer.dart';
import 'package:dating_app/features/matching/domain/match_weights.dart';
import 'package:dating_app/features/matching/domain/ranked_feed_state.dart';
import 'package:dating_app/features/matching/domain/scored_profile.dart';
import 'package:dating_app/features/safety/application/safety_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'discovery_controller.g.dart';

/// The single Discovery feed controller for the "All" tab.
///
/// Phase 2.2: replaces the legacy pagination-only controller with
/// a scored variant. When the [matchingEngineEnabled] feature flag
/// is off, scoring is skipped and the controller degenerates to the
/// legacy age-ordered feed (same behavior as Phase 2.0/2.1).
@riverpod
class DiscoveryController extends _$DiscoveryController {
  static const int _pageSize = 20;
  static const int _maxPagesPerFetch = 5;

  @override
  RankedFeedState<ScoredProfile> build() =>
      const RankedFeedState<ScoredProfile>();

  Future<void> loadInitial() async {
    if (state.status != FeedStatus.initial) return;
    await _fetch(reset: true);
  }

  Future<void> refresh() => _fetch(reset: true);

  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.status == FeedStatus.loading ||
        state.status == FeedStatus.loadingMore) {
      return;
    }
    await _fetch(reset: false);
  }

  Future<void> _fetch({required bool reset}) async {
    final DiscoveryFilters filters =
        ref.read(discoveryFiltersControllerProvider);
    final ViewerContext viewer = ref.read(viewerContextProvider);
    final bool matchingOn =
        ref.read(envConfigProvider).matchingEngineEnabled;
    final MatchWeights weights = MatchWeights.forAll;
    final MatchScorer scorer = ref.read(matchScorerProvider);
    final String? myUid = ref.read(authStateChangesProvider).value?.uid;
    final Set<String> blocked =
        ref.read(blockedUidsProvider).value ?? const <String>{};
    final MatchPreferences viewerPrefs =
        ref.read(currentMatchPreferencesProvider).value ??
            MatchPreferences.defaults(null);

    state = state.copyWith(
      status: reset ? FeedStatus.loading : FeedStatus.loadingMore,
      items: reset ? <ScoredProfile>[] : null,
      hasMore: reset ? true : null,
      cursor: reset ? null : state.cursor,
      clearError: true,
    );

    final List<ScoredProfile> collected = <ScoredProfile>[];
    Object? cursor = reset ? null : state.cursor;
    bool hasMore = true;
    int pages = 0;

    try {
      while (collected.isEmpty && hasMore && pages < _maxPagesPerFetch) {
        pages++;
        final page = await ref.read(discoveryRepositoryProvider).fetchPage(
              minAge: filters.minAge,
              maxAge: filters.maxAge,
              cursor: cursor,
              limit: _pageSize,
            );
        cursor = page.nextCursor;
        hasMore = page.hasMore;
        for (final PublicProfile p in page.profiles) {
          if (p.uid == myUid) continue;
          if (blocked.contains(p.uid)) continue;
          if (!filters.matches(p)) continue;
          if (!matchingOn) {
            // Legacy path — emit a ScoredProfile with a neutral
            // score so the UI doesn't have to branch.
            collected.add(
              ScoredProfile(
                profile: p,
                score: 0,
                terms: const <String, double>{},
              ),
            );
            continue;
          }
          final ScoredProfile? scored = scorer.evaluate(
            viewer: viewer,
            subject: p,
            viewerPrefs: viewerPrefs,
            blockedUids: blocked,
            weights: weights,
          );
          if (scored == null) continue;
          collected.add(scored);
        }
      }

      if (matchingOn) {
        // Sort by score DESC, stable on uid.
        collected.sort((ScoredProfile a, ScoredProfile b) {
          final int c = b.score.compareTo(a.score);
          if (c != 0) return c;
          return a.profile.uid.compareTo(b.profile.uid);
        });
      }

      final List<ScoredProfile> merged = reset
          ? collected
          : <ScoredProfile>[...state.items, ...collected];

      state = RankedFeedState<ScoredProfile>(
        items: _dedupe(merged),
        status: FeedStatus.loaded,
        hasMore: hasMore,
        cursor: cursor,
      );
    } catch (_) {
      state = state.copyWith(
        status: FeedStatus.error,
        errorMessage: 'Could not load people right now. Please try again.',
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
