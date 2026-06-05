import 'package:dating_app/core/firebase/firebase_providers.dart';
import 'package:dating_app/features/discovery/data/firestore_discovery_repository.dart';
import 'package:dating_app/features/discovery/data/firestore_nearby_search_repository.dart';
import 'package:dating_app/features/discovery/data/geolocator_location_repository.dart';
import 'package:dating_app/features/discovery/domain/discovery_repository.dart';
import 'package:dating_app/features/discovery/domain/location_repository.dart';
import 'package:dating_app/features/discovery/domain/nearby_search_repository.dart';
import 'package:dating_app/features/discovery/domain/public_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'discovery_providers.g.dart';

/// The app's [DiscoveryRepository] (Firestore-backed).
@Riverpod(keepAlive: true)
DiscoveryRepository discoveryRepository(Ref ref) =>
    FirestoreDiscoveryRepository(ref.watch(firebaseFirestoreProvider));

/// One public profile by id (detail screen / deep links).
@riverpod
Future<PublicProfile?> profileById(Ref ref, String uid) =>
    ref.watch(discoveryRepositoryProvider).fetchProfile(uid);

/// The app's [NearbySearchRepository] (Firestore-backed, geohash-bucketed).
@Riverpod(keepAlive: true)
NearbySearchRepository nearbySearchRepository(Ref ref) =>
    FirestoreNearbySearchRepository(ref.watch(firebaseFirestoreProvider));

/// The app's [LocationRepository] (`geolocator` + Firestore-backed).
@Riverpod(keepAlive: true)
LocationRepository locationRepository(Ref ref) =>
    GeolocatorLocationRepository(ref.watch(firebaseFirestoreProvider));
