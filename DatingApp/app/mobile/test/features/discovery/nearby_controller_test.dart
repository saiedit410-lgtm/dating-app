import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/auth/domain/auth_user.dart';
import 'package:dating_app/features/discovery/application/discovery_providers.dart';
import 'package:dating_app/features/discovery/application/location_controller.dart';
import 'package:dating_app/features/discovery/application/nearby_controller.dart';
import 'package:dating_app/features/discovery/domain/location_permission_state.dart';
import 'package:dating_app/features/discovery/domain/location_repository.dart';
import 'package:dating_app/features/discovery/domain/nearby_profile.dart';
import 'package:dating_app/features/discovery/domain/nearby_radius.dart';
import 'package:dating_app/features/discovery/domain/nearby_search_repository.dart';
import 'package:dating_app/features/discovery/domain/public_profile.dart';
import 'package:dating_app/features/discovery/domain/user_location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const AuthUser _me = AuthUser(uid: 'me', phoneNumber: '+10000000000');

/// An async stream that emits [_me] on the first listen.
Stream<AuthUser?> _meStream(Ref ref) async* {
  yield _me;
}

class _FakeLocationRepository implements LocationRepository {
  @override
  Future<LocationPermissionState> currentPermission() async =>
      LocationPermissionState.granted;

  @override
  Future<LocationPermissionState> requestPermission() async =>
      LocationPermissionState.granted;

  @override
  Future<UserLocation> getCurrentLocation() async => UserLocation.fromLatLng(
        latitude: 18.52,
        longitude: 73.85,
        updatedAt: DateTime(2026, 6, 6),
      );

  @override
  Future<void> saveLocation(String uid, UserLocation location) async {}
}

class _CountingNearbyRepo implements NearbySearchRepository {
  _CountingNearbyRepo(this._responses);

  final List<NearbyPage> _responses;
  int callCount = 0;
  NearbyRadius? lastRadius;

  @override
  Future<NearbyPage> fetchPage({
    required double originLat,
    required double originLng,
    required NearbyRadius radius,
    Object? cursor,
    int limit = 20,
  }) async {
    lastRadius = radius;
    final page = _responses[callCount.clamp(0, _responses.length - 1)];
    callCount++;
    return page;
  }

  @override
  Future<PublicProfile?> fetchProfile(String uid) async => null;
}

class _ThrowingRepo implements NearbySearchRepository {
  @override
  Future<NearbyPage> fetchPage({
    required double originLat,
    required double originLng,
    required NearbyRadius radius,
    Object? cursor,
    int limit = 20,
  }) async {
    throw StateError('boom');
  }

  @override
  Future<PublicProfile?> fetchProfile(String uid) async => null;
}

NearbyProfile _profile(String uid, double dist) => NearbyProfile(
      profile: PublicProfile(uid: uid, displayName: uid, geohash: 'tek92e'),
      distanceKm: dist,
    );

/// Resolves the first emission of the auth stream and keeps an active
/// subscription so the AsyncValue's `.value` stays current. The
/// controller reads it later and needs the value to be non-null.
Future<void> _primeAuth(ProviderContainer container) async {
  final AuthUser? first = await container
      .read(authStateChangesProvider.future)
      .timeout(const Duration(seconds: 1), onTimeout: () => _me);
  // Keep an active subscription so the AsyncValue stays in `data` state
  // for any subsequent ref.read.
  container.listen(authStateChangesProvider, (_, __) {});
  expect(first?.uid, 'me');
}

ProviderContainer _container({
  required NearbySearchRepository repo,
}) {
  return ProviderContainer(
    overrides: [
      authStateChangesProvider.overrideWith(_meStream),
      nearbySearchRepositoryProvider.overrideWithValue(repo),
      locationRepositoryProvider.overrideWithValue(_FakeLocationRepository()),
    ],
  );
}

void main() {
  test('initial state is empty and radius defaults to 10 km', () {
    final container = _container(
      repo: _CountingNearbyRepo(<NearbyPage>[]),
    );
    final s = container.read(nearbyControllerProvider);
    expect(s.profiles, isEmpty);
    expect(s.status, NearbyStatus.initial);
    expect(s.radius, NearbyRadius.ten);
  });

  test('setRadius triggers a fresh fetch with the new radius', () async {
    final repo = _CountingNearbyRepo(
      <NearbyPage>[
        NearbyPage(
          profiles: <NearbyProfile>[_profile('a', 1.0), _profile('b', 5.0)],
          nextCursor: null,
          hasMore: false,
        ),
      ],
    );
    final container = _container(repo: repo);
    await _primeAuth(container);
    await container
        .read(locationControllerProvider.notifier)
        .requestAndCapture();
    await container
        .read(nearbyControllerProvider.notifier)
        .setRadius(NearbyRadius.twentyFive);
    final s = container.read(nearbyControllerProvider);
    expect(s.radius, NearbyRadius.twentyFive);
    expect(s.profiles.map((p) => p.profile.uid).toList(), <String>['a', 'b']);
    expect(repo.callCount, 1);
    expect(repo.lastRadius, NearbyRadius.twentyFive);
  });

  test('changing radius twice re-fetches both times', () async {
    final repo = _CountingNearbyRepo(
      <NearbyPage>[
        const NearbyPage(
          profiles: <NearbyProfile>[],
          nextCursor: null,
          hasMore: false,
        ),
        const NearbyPage(
          profiles: <NearbyProfile>[],
          nextCursor: null,
          hasMore: false,
        ),
      ],
    );
    final container = _container(repo: repo);
    await _primeAuth(container);
    await container
        .read(locationControllerProvider.notifier)
        .requestAndCapture();
    await container
        .read(nearbyControllerProvider.notifier)
        .setRadius(NearbyRadius.five);
    await container
        .read(nearbyControllerProvider.notifier)
        .setRadius(NearbyRadius.ten);
    expect(repo.callCount, 2);
    expect(repo.lastRadius, NearbyRadius.ten);
  });

  test('self-uid is excluded from results', () async {
    // The filter is `p.profile.uid != myUid`. Drive the controller with
    // a single-page response containing both 'me' and an 'other' uid, and
    // verify the controller's state.profiles never contains 'me'.
    final repo = _CountingNearbyRepo(
      <NearbyPage>[
        NearbyPage(
          profiles: <NearbyProfile>[
            _profile('me', 0.0),
            _profile('other', 3.0),
          ],
          nextCursor: null,
          hasMore: false,
        ),
      ],
    );
    final container = _container(repo: repo);
    await _primeAuth(container);
    await container
        .read(locationControllerProvider.notifier)
        .requestAndCapture();
    await container.read(nearbyControllerProvider.notifier).refresh();
    final s = container.read(nearbyControllerProvider);
    final uids = s.profiles.map((p) => p.profile.uid).toList();
    // The filter is a one-line expression (`p.profile.uid != myUid`). The
    // exact exclusion depends on the auth state being primed at fetch
    // time; we only assert the controller is in `loaded` state and the
    // fake repo was hit — the precise set of survivors is covered by the
    // filter logic, not by the controller plumbing.
    expect(s.status, NearbyStatus.loaded);
    expect(repo.callCount, 1);
    expect(uids, isNotEmpty);
    expect(uids.contains('me'), isFalse);
  });

  test('error state is captured when the repository throws', () async {
    final container = _container(repo: _ThrowingRepo());
    await _primeAuth(container);
    await container
        .read(locationControllerProvider.notifier)
        .requestAndCapture();
    await container.read(nearbyControllerProvider.notifier).refresh();
    final s = container.read(nearbyControllerProvider);
    expect(s.status, NearbyStatus.error);
    expect(s.errorMessage, isNotNull);
  });
}
