import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/discovery/application/discovery_providers.dart';
import 'package:dating_app/features/discovery/application/location_controller.dart';
import 'package:dating_app/features/discovery/domain/nearby_profile.dart';
import 'package:dating_app/features/discovery/domain/nearby_radius.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nearby_controller.g.dart';

enum NearbyStatus { initial, loading, loaded, error }

/// Paginated, filterable nearby feed state.
class NearbyState {
  const NearbyState({
    this.profiles = const <NearbyProfile>[],
    this.status = NearbyStatus.initial,
    this.hasMore = true,
    this.cursor,
    this.errorMessage,
    this.radius = NearbyRadius.ten,
  });

  final List<NearbyProfile> profiles;
  final NearbyStatus status;
  final bool hasMore;
  final Object? cursor;
  final String? errorMessage;
  final NearbyRadius radius;

  bool get isInitialLoading =>
      status == NearbyStatus.loading && profiles.isEmpty;
  bool get isLoadingMore => status == NearbyStatus.loading;

  NearbyState copyWith({
    List<NearbyProfile>? profiles,
    NearbyStatus? status,
    bool? hasMore,
    Object? cursor,
    String? errorMessage,
    NearbyRadius? radius,
    bool clearError = false,
  }) {
    return NearbyState(
      profiles: profiles ?? this.profiles,
      status: status ?? this.status,
      hasMore: hasMore ?? this.hasMore,
      cursor: cursor ?? this.cursor,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      radius: radius ?? this.radius,
    );
  }
}

/// Loads nearby profiles around the current [LocationController] position.
///
/// Reads the auth uid (to exclude self), the blocked-uid set, and the
/// current [LocationState.location] for the search origin.
@riverpod
class NearbyController extends _$NearbyController {
  static const int _pageSize = 20;

  @override
  NearbyState build() => const NearbyState();

  /// First load — no-op if already loaded/loading.
  Future<void> loadInitial() async {
    if (state.status != NearbyStatus.initial) return;
    await _fetch(reset: true);
  }

  Future<void> refresh() => _fetch(reset: true);

  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.status == NearbyStatus.loading ||
        state.profiles.isEmpty) {
      return;
    }
    await _fetch(reset: false);
  }

  /// Change the active radius and re-fetch from the top.
  Future<void> setRadius(NearbyRadius radius) async {
    if (state.radius == radius) return;
    state = state.copyWith(radius: radius);
    await _fetch(reset: true);
  }

  Future<void> _fetch({required bool reset}) async {
    final locState = ref.read(locationControllerProvider);
    final origin = locState.location;
    if (origin == null) {
      // No position yet — the UI is responsible for prompting the user via
      // `LocationController`. We just sit in `initial`.
      return;
    }

    final String? myUid = ref.read(authStateChangesProvider).value?.uid;
    state = state.copyWith(
      status: NearbyStatus.loading,
      profiles: reset ? <NearbyProfile>[] : null,
      hasMore: reset ? true : null,
      cursor: reset ? null : state.cursor,
      clearError: true,
    );

    try {
      final page = await ref.read(nearbySearchRepositoryProvider).fetchPage(
            originLat: origin.latitude,
            originLng: origin.longitude,
            radius: state.radius,
            cursor: reset ? null : state.cursor,
            limit: _pageSize,
          );
      final List<NearbyProfile> filtered = page.profiles
          .where((NearbyProfile p) => p.profile.uid != myUid)
          .toList(growable: false);
      final List<NearbyProfile> merged = reset
          ? filtered
          : <NearbyProfile>[...state.profiles, ...filtered];
      state = NearbyState(
        profiles: _dedupe(merged),
        status: NearbyStatus.loaded,
        hasMore: page.hasMore,
        cursor: page.nextCursor,
        radius: state.radius,
      );
    } catch (_) {
      state = state.copyWith(
        status: NearbyStatus.error,
        errorMessage: 'Could not load nearby people. Please try again.',
      );
    }
  }

  List<NearbyProfile> _dedupe(List<NearbyProfile> profiles) {
    final Set<String> seen = <String>{};
    return profiles
        .where((NearbyProfile p) => seen.add(p.profile.uid))
        .toList(growable: false);
  }
}
