import 'dart:math' as math;

/// Haversine helpers — pure Dart, no Flutter dependency.
///
/// Earth's mean radius in kilometers (WGS-84 spherical approximation; good
/// to ~0.5% which is far below the precision of any geohash bucket).
const double _earthRadiusKm = 6371.0;

/// Great-circle distance in **kilometers** between two coordinates.
double haversineKm(
  double lat1,
  double lng1,
  double lat2,
  double lng2,
) {
  final double dLat = _toRad(lat2 - lat1);
  final double dLng = _toRad(lng2 - lng1);
  final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRad(lat1)) *
          math.cos(_toRad(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return _earthRadiusKm * c;
}

/// Formats a distance in km for display on a card: e.g. "0.3 km", "2 km",
/// "12 km", or "> 100 km" if outside the range we show.
String formatDistanceKm(double km) {
  if (!km.isFinite || km < 0) return '—';
  if (km < 1) return '${(km * 1000).round()} m';
  if (km < 10) return '${km.toStringAsFixed(1)} km';
  if (km < 100) return '${km.round()} km';
  return '> 100 km';
}

double _toRad(double deg) => deg * math.pi / 180.0;
