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
import 'package:dating_app/features/profile/domain/profile_enums.dart';
import 'package:dating_app/features/matching/domain/feed_status.dart';
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
      profile: PublicProfile(
        uid: uid,
        displayName: uid,
        age: 25,
        gender: Gender.male,
        interestedIn: const <Gender>[],
        geohash: 'tek92e',
      ),
      distanceKm: dist,
    );

/// Resolves the first emission of the auth stream and keeps an active
/// subscription so the AsyncValue's `.value` stays current.
Future<void> _primeAuth(ProviderContainer container) async {
  await container
      .read(authStateChangesProvider.future)
      .timeout(const Duration(seconds: 1), onTimeout: () => _me);
  container.listen(authStateChangesProvider, (_, _) {});
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
    expect(s.items, isEmpty);
    expect(s.status, FeedStatus.initial);
    expect(container.read(nearbyRadiusControllerProvider), NearbyRadius.ten);
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
    expect(container.read(nearbyRadiusControllerProvider),
        NearbyRadius.twentyFive);
    expect(s.items.map((p) => p.profile.uid).toList(), <String>['a', 'b']);
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
    final uids = s.items.map((p) => p.profile.uid).toList();
    expect(s.status, FeedStatus.loaded);
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
    expect(s.status, FeedStatus.error);
    expect(s.errorMessage, isNotNull);
  });
}
