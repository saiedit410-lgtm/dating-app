import 'package:dating_app/features/discovery/domain/geo/distance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('haversineKm', () {
    test('zero distance for the same point', () {
      expect(haversineKm(18.52, 73.85, 18.52, 73.85), closeTo(0, 0.001));
    });

    test('Pune -> Mumbai is ~120 km', () {
      // Pune (18.5204, 73.8567) -> Mumbai (19.0760, 72.8777).
      // Reference: 118-122 km great-circle distance.
      final double km = haversineKm(18.5204, 73.8567, 19.0760, 72.8777);
      expect(km, inInclusiveRange(115, 130));
    });

    test('London -> New York is ~5570 km', () {
      final double km = haversineKm(51.5074, -0.1278, 40.7128, -74.0060);
      expect(km, inInclusiveRange(5500, 5650));
    });

    test('symmetric: A->B == B->A', () {
      final double a = haversineKm(12.97, 77.59, 28.61, 77.20);
      final double b = haversineKm(28.61, 77.20, 12.97, 77.59);
      expect(a, closeTo(b, 0.0001));
    });
  });

  group('formatDistanceKm', () {
    test('formats sub-kilometer as meters', () {
      expect(formatDistanceKm(0.123), '123 m');
    });

    test('formats single-digit km with one decimal', () {
      expect(formatDistanceKm(2.7), '2.7 km');
    });

    test('rounds double-digit km to nearest integer', () {
      expect(formatDistanceKm(12.3), '12 km');
    });

    test('clamps huge distances to "> 100 km"', () {
      expect(formatDistanceKm(5500), '> 100 km');
    });

    test('replaces invalid values with a dash', () {
      expect(formatDistanceKm(double.nan), '—');
      expect(formatDistanceKm(-1), '—');
    });
  });
}
