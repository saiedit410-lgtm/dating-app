import 'package:dating_app/features/discovery/domain/geo/geohash.dart';

/// The signed-in user's device location, plus the geohash that goes onto
/// their **public** profile for nearby search.
///
/// Coordinates here are the "exact" reading from the platform. The public
/// `users/{uid}` document only ever sees the [geohash] + [geohashPrefixes];
/// the exact pair is mirrored to `users/{uid}/private/data` (owner + admin
/// only — see `backend/firestore/firestore.rules`).
class UserLocation {
  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.geohash,
    required this.geohashPrefixes,
    required this.locationUpdatedAt,
  });

  /// Builds a [UserLocation] from raw (lat, lng). Encodes the geohash and
  /// computes a single-prefix list for radius bucketing.
  factory UserLocation.fromLatLng({
    required double latitude,
    required double longitude,
    required DateTime updatedAt,
  }) {
    return UserLocation(
      latitude: latitude,
      longitude: longitude,
      geohash: encodeGeohash(latitude, longitude),
      geohashPrefixes: _buildPrefixes(latitude, longitude),
      locationUpdatedAt: updatedAt,
    );
  }

  /// Builds from a public `users/{uid}` document — only the geohash + its
  /// last-update time are present here (no exact coords on public).
  factory UserLocation.fromPublicMap(Map<String, dynamic> data) {
    return UserLocation(
      latitude: 0,
      longitude: 0,
      geohash: (data['geohash'] as String?) ?? '',
      geohashPrefixes: ((data['geohashPrefixes'] as List<dynamic>?) ??
              <dynamic>[])
          .map((dynamic e) => e as String)
          .toList(growable: false),
      locationUpdatedAt:
          (data['locationUpdatedAt'] is DateTime)
              ? data['locationUpdatedAt'] as DateTime
              : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final double latitude;
  final double longitude;
  final String geohash;

  /// Geohash prefixes of various lengths, used as Firestore
  /// `array-contains` candidates for nearby queries.
  final List<String> geohashPrefixes;
  final DateTime locationUpdatedAt;

  static const int _prefixStartLen = 3;
  static const int _prefixEndLen = 6;

  static List<String> _buildPrefixes(double lat, double lng) {
    final String hash = encodeGeohash(lat, lng, precision: _prefixEndLen);
    if (hash.length < _prefixStartLen) return <String>[hash];
    final Set<String> out = <String>{};
    for (int n = _prefixStartLen; n <= _prefixEndLen; n++) {
      out.add(hash.substring(0, n));
    }
    return out.toList(growable: false);
  }
}
