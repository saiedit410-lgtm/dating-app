import 'package:dating_app/features/discovery/domain/nearby_profile.dart';
import 'package:dating_app/features/discovery/domain/nearby_radius.dart';
import 'package:dating_app/features/discovery/domain/public_profile.dart';

/// A single page of nearby search results. Uses the same opaque-cursor
/// pagination shape as `DiscoveryPage` so the UI can render it identically.
class NearbyPage {
  const NearbyPage({
    required this.profiles,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<NearbyProfile> profiles;
  final Object? nextCursor;
  final bool hasMore;
}

/// Reads nearby discoverable profiles around an origin (lat, lng) within
/// [radiusKm], sorted by ascending distance.
///
/// Implementation lives in the data layer (Firestore-backed). The
/// repository is responsible for:
///   1. Issuing the bucket query against `geohashPrefixes`.
///   2. Filtering client-side by [haversineKm] within the radius.
///   3. Excluding self, blocked, and existing connections.
abstract interface class NearbySearchRepository {
  Future<NearbyPage> fetchPage({
    required double originLat,
    required double originLng,
    required NearbyRadius radius,
    Object? cursor,
    int limit = 20,
  });

  /// One public profile by id (mirrors `DiscoveryRepository.fetchProfile`).
  Future<PublicProfile?> fetchProfile(String uid);
}
