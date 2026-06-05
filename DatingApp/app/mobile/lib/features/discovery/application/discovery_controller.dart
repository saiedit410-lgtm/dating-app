import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/discovery/application/discovery_filters_controller.dart';
import 'package:dating_app/features/discovery/application/discovery_providers.dart';
import 'package:dating_app/features/discovery/domain/discovery_filters.dart';
import 'package:dating_app/features/discovery/domain/public_profile.dart';
import 'package:dating_app/features/safety/application/safety_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'discovery_controller.g.dart';

enum DiscoveryStatus { initial, loading, loadingMore, loaded, error }

/// Paginated, filtered discovery feed state.
class DiscoveryState {
  const DiscoveryState({
    this.profiles = const <PublicProfile>[],
    this.status = DiscoveryStatus.initial,
    this.hasMore = true,
    this.cursor,
    this.errorMessage,
  });

  final List<PublicProfile> profiles;
  final DiscoveryStatus status;
  final bool hasMore;
  final Object? cursor;
  final String? errorMessage;

  bool get isInitialLoading =>
      status == DiscoveryStatus.loading && profiles.isEmpty;
  bool get isLoadingMore => status == DiscoveryStatus.loadingMore;

  DiscoveryState copyWith({
    List<PublicProfile>? profiles,
    DiscoveryStatus? status,
    bool? hasMore,
    Object? cursor,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DiscoveryState(
      profiles: profiles ?? this.profiles,
      status: status ?? this.status,
      hasMore: hasMore ?? this.hasMore,
      cursor: cursor ?? this.cursor,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Loads discoverable profiles with cursor-based pagination, applying
/// self-exclusion, the block list, and client-side filters per page.
@riverpod
class DiscoveryController extends _$DiscoveryController {
  static const int _pageSize = 20;
  static const int _maxPagesPerFetch = 5;

  @override
  DiscoveryState build() => const DiscoveryState();

  /// First load (no-op if already loaded/loading).
  Future<void> loadInitial() async {
    if (state.status != DiscoveryStatus.initial) return;
    await _fetch(reset: true);
  }

  Future<void> refresh() => _fetch(reset: true);

  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.status == DiscoveryStatus.loading ||
        state.status == DiscoveryStatus.loadingMore) {
      return;
    }
    await _fetch(reset: false);
  }

  Future<void> _fetch({required bool reset}) async {
    final DiscoveryFilters filters = ref.read(
      discoveryFiltersControllerProvider,
    );
    final String? myUid = ref.read(authStateChangesProvider).value?.uid;
    final Set<String> blocked =
        ref.read(blockedUidsProvider).value ?? const <String>{};

    state = state.copyWith(
      status: reset ? DiscoveryStatus.loading : DiscoveryStatus.loadingMore,
      profiles: reset ? <PublicProfile>[] : null,
      hasMore: reset ? true : null,
      cursor: reset ? null : state.cursor,
      clearError: true,
    );

    final List<PublicProfile> collected = <PublicProfile>[];
    Object? cursor = reset ? null : state.cursor;
    bool hasMore = true;
    int pages = 0;

    try {
      while (collected.isEmpty && hasMore && pages < _maxPagesPerFetch) {
        pages++;
        final page = await ref
            .read(discoveryRepositoryProvider)
            .fetchPage(
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
          collected.add(p);
        }
      }

      final List<PublicProfile> merged = reset
          ? collected
          : <PublicProfile>[...state.profiles, ...collected];

      state = DiscoveryState(
        profiles: _dedupe(merged),
        status: DiscoveryStatus.loaded,
        hasMore: hasMore,
        cursor: cursor,
      );
    } catch (_) {
      state = state.copyWith(
        status: DiscoveryStatus.error,
        errorMessage: 'Could not load people right now. Please try again.',
      );
    }
  }

  List<PublicProfile> _dedupe(List<PublicProfile> profiles) {
    final Set<String> seen = <String>{};
    return profiles
        .where((PublicProfile p) => seen.add(p.uid))
        .toList(growable: false);
  }
}
