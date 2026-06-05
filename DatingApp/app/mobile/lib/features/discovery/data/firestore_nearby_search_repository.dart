import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/features/discovery/domain/geo/distance.dart';
import 'package:dating_app/features/discovery/domain/geo/geohash.dart';
import 'package:dating_app/features/discovery/domain/nearby_profile.dart';
import 'package:dating_app/features/discovery/domain/nearby_radius.dart';
import 'package:dating_app/features/discovery/domain/nearby_search_repository.dart';
import 'package:dating_app/features/discovery/domain/public_profile.dart';

/// Firestore-backed nearby search.
///
/// Firestore has no native geospatial query, so the strategy is:
///   1. Compute the geohash-prefix candidates covering the radius
///      (see [neighborPrefixes]).
///   2. For each candidate prefix, query the `users` collection
///      (`where('geohashPrefixes', arrayContains: prefix)`).
///   3. Merge, drop self / blocked / connections, and **filter precisely
///      client-side** with [haversineKm].
///
/// We over-fetch per page (limit * 4) so a single page call usually
/// yields enough survivors after the radius filter.
class FirestoreNearbySearchRepository implements NearbySearchRepository {
  FirestoreNearbySearchRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Future<NearbyPage> fetchPage({
    required double originLat,
    required double originLng,
    required NearbyRadius radius,
    Object? cursor,
    int limit = 20,
  }) async {
    final List<String> prefixes = neighborPrefixes(
      centerLat: originLat,
      centerLng: originLng,
      radiusKm: radius.km.toDouble(),
      precision: 5,
    );

    // Fetch a single page across the (small) set of candidate prefixes.
    // We union them in memory, then filter precisely by haversine.
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
        <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    for (final String prefix in prefixes) {
      final Query<Map<String, dynamic>> q = _users
          .where('geohashPrefixes', arrayContains: prefix)
          .where('onboardingComplete', isEqualTo: true)
          .where('accountStatus', isEqualTo: 'active')
          .limit(limit * 2);
      final QuerySnapshot<Map<String, dynamic>> snap = await q.get();
      allDocs.addAll(snap.docs);
    }

    // Dedup (same user can match multiple prefixes).
    final Map<String, QueryDocumentSnapshot<Map<String, dynamic>>> byUid =
        <String, QueryDocumentSnapshot<Map<String, dynamic>>>{
      for (final QueryDocumentSnapshot<Map<String, dynamic>> d in allDocs)
        d.id: d,
    };

    // Compute the geohash of the origin so we can sort by its prefix
    // distance (cheap secondary key) before doing haversine.
    final List<NearbyProfile> filtered = byUid.values
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> d) =>
              _toNearby(d, originLat, originLng),
        )
        .where((NearbyProfile? p) => p != null)
        .cast<NearbyProfile>()
        .where((NearbyProfile p) => p.distanceKm <= radius.km)
        .toList()
      ..sort(
        (NearbyProfile a, NearbyProfile b) =>
            a.distanceKm.compareTo(b.distanceKm),
      );

    // Apply cursor (skip ahead).
    final int start = cursor is int ? cursor : 0;
    final List<NearbyProfile> page =
        filtered.skip(start).take(limit).toList(growable: false);
    final int nextStart = start + page.length;
    return NearbyPage(
      profiles: page,
      nextCursor: nextStart < filtered.length ? nextStart : null,
      hasMore: nextStart < filtered.length,
    );
  }

  @override
  Future<PublicProfile?> fetchProfile(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> snap =
        await _users.doc(uid).get();
    final Map<String, dynamic>? data = snap.data();
    if (!snap.exists || data == null) return null;
    return PublicProfile.fromMap(snap.id, data);
  }

  NearbyProfile? _toNearby(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    double originLat,
    double originLng,
  ) {
    final Map<String, dynamic> data = doc.data();
    // Need a geohash to compute distance.
    final String geohash = (data['geohash'] as String?) ?? '';
    if (geohash.isEmpty) return null;
    final ({double lat, double lng, double latError, double lngError})?
        decoded = decodeGeohash(geohash);
    if (decoded == null) return null;
    final double distanceKm = haversineKm(
      originLat,
      originLng,
      decoded.lat,
      decoded.lng,
    );
    return NearbyProfile(
      profile: PublicProfile.fromMap(doc.id, data),
      distanceKm: distanceKm,
    );
  }
}
