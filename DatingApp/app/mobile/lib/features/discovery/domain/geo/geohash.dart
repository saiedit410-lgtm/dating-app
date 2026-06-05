/// Pure-Dart Geohash encoder/decoder (Niemeyer base32, 2008).
///
/// Geohash is a public domain algorithm (https://geohash.org) — implemented
/// here in-tree to avoid pulling in a Dart-2-only transitive dependency. It
/// is used for **coarse** radius bucketing in Firestore (which has no native
/// geospatial query): the user's public profile stores a short geohash, and a
/// nearby search queries a small set of candidate prefixes.
///
/// Precise distance is then computed client-side from the **owner-only**
/// private coordinates via `Haversine` in `distance.dart` — see
/// `docs/DatabaseSchema.md` for the privacy rationale.
library;

import 'dart:math' as math;

/// Base32 alphabet used by the geohash standard.
const String _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

/// Encodes a (lat, lng) pair into a geohash of [precision] characters.
///
/// `precision` must be in 1..12. Returns a lowercase string.
String encodeGeohash(double lat, double lng, {int precision = 6}) {
  if (precision < 1 || precision > 12) {
    throw ArgumentError.value(precision, 'precision', 'must be in 1..12');
  }
  if (lat < -90 || lat > 90) {
    throw ArgumentError.value(lat, 'lat', 'must be in [-90, 90]');
  }
  if (lng < -180 || lng > 180) {
    throw ArgumentError.value(lng, 'lng', 'must be in [-180, 180]');
  }

  double latLo = -90;
  double latHi = 90;
  double lngLo = -180;
  double lngHi = 180;

  final StringBuffer hash = StringBuffer();
  int bits = 0;
  int bit = 0;
  bool even = true; // start with longitude

  while (hash.length < precision) {
    if (even) {
      final double mid = (lngLo + lngHi) / 2;
      if (lng >= mid) {
        bits = (bits << 1) | 1;
        lngLo = mid;
      } else {
        bits = bits << 1;
        lngHi = mid;
      }
    } else {
      final double mid = (latLo + latHi) / 2;
      if (lat >= mid) {
        bits = (bits << 1) | 1;
        latLo = mid;
      } else {
        bits = bits << 1;
        latHi = mid;
      }
    }
    even = !even;
    bit++;
    if (bit == 5) {
      hash.write(_base32[bits]);
      bits = 0;
      bit = 0;
    }
  }
  return hash.toString();
}

/// Decodes a geohash back into the (lat, lng) of its **center** cell, plus
/// the half-width/height of the cell.
///
/// Returns null if [geohash] contains characters outside the base32 alphabet.
({double lat, double lng, double latError, double lngError})? decodeGeohash(
  String geohash,
) {
  if (geohash.isEmpty) return null;
  final String normalized = geohash.toLowerCase();
  double latLo = -90;
  double latHi = 90;
  double lngLo = -180;
  double lngHi = 180;
  bool even = true;

  for (int i = 0; i < normalized.length; i++) {
    final int idx = _base32.indexOf(normalized[i]);
    if (idx < 0) return null;

    for (int n = 4; n >= 0; n--) {
      final int bitN = (idx >> n) & 1;
      if (even) {
        final double mid = (lngLo + lngHi) / 2;
        if (bitN == 1) {
          lngLo = mid;
        } else {
          lngHi = mid;
        }
      } else {
        final double mid = (latLo + latHi) / 2;
        if (bitN == 1) {
          latLo = mid;
        } else {
          latHi = mid;
        }
      }
      even = !even;
    }
  }
  return (
    lat: (latLo + latHi) / 2,
    lng: (lngLo + lngHi) / 2,
    latError: (latHi - latLo) / 2,
    lngError: (lngHi - lngLo) / 2,
  );
}

/// Returns the list of geohash **prefixes** (length [precision]) whose cells
/// may contain points within [radiusKm] of ([centerLat], [centerLng]).
///
/// These are used as `array-contains` candidates on `users.geohashPrefixes`:
/// any user whose prefix list contains at least one of these is *possibly*
/// within range. The exact distance is then computed client-side using
/// `Haversine.distanceKm` — see `distance.dart`.
List<String> neighborPrefixes({
  required double centerLat,
  required double centerLng,
  required double radiusKm,
  int precision = 5,
}) {
  if (precision < 1 || precision > 12) {
    throw ArgumentError.value(precision, 'precision', 'must be in 1..12');
  }
  final String center = encodeGeohash(centerLat, centerLng, precision: precision);
  if (radiusKm <= 0) return <String>[center];

  // Approximate the cell's half-extent (worst case between lat/lng).
  // 5 bits per char; (2*precision - 1) bits per dimension for the smaller
  // side, so 2*precision is the *full* extent in bits for the larger side.
  // We use the larger side to be safe (over-bucket rather than miss).
  final double cellLat = _halfCellDegrees(precision).lat;
  final double cellLng = _halfCellDegrees(precision).lng;
  final double halfLat = (radiusKm / 111.0);
  final double halfLng =
      radiusKm / (111.0 * math.max(0.0001, math.cos(centerLat * math.pi / 180)));

  // Step in 1-cell increments until we cover the half-extent.
  final int latSteps = math.max(1, (halfLat / cellLat).ceil());
  final int lngSteps = math.max(1, (halfLng / cellLng).ceil());

  final Set<String> cells = <String>{center};
  for (int dLat = -latSteps; dLat <= latSteps; dLat++) {
    for (int dLng = -lngSteps; dLng <= lngSteps; dLng++) {
      if (dLat == 0 && dLng == 0) continue;
      final double lat =
          (centerLat + dLat * cellLat).clamp(-90.0, 90.0).toDouble();
      final double lng =
          (centerLng + dLng * cellLng).clamp(-180.0, 180.0).toDouble();
      cells.add(encodeGeohash(lat, lng, precision: precision));
    }
  }
  return cells.toList(growable: false);
}

/// Half-width of a geohash cell at the equator in degrees.
({double lat, double lng}) _halfCellDegrees(int precision) {
  // 5 bits per char; with 2*precision bits total, the half-extent of a
  // cell in one dimension is 180/2^(2*precision - 1) (rough overestimate).
  final double lat = 180.0 / (1 << ((2 * precision - 1).clamp(1, 30)));
  final double lng = 360.0 / (1 << ((2 * precision - 1).clamp(1, 30)));
  return (lat: lat, lng: lng);
}
