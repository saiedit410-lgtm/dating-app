import 'package:dating_app/features/discovery/domain/geo/geohash.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('encodeGeohash', () {
    test('encodes a known point at length 6', () {
      // Pune, MH — geohash precision 5 = 'tek92' (computed live by the
      // encoder; precision 6 adds one base32 char).
      final String hash = encodeGeohash(18.5204, 73.8567, precision: 6);
      expect(hash.length, 6);
      expect(hash.startsWith('tek92'), isTrue);
    });

    test('encodes shorter and longer precisions', () {
      expect(encodeGeohash(0, 0, precision: 1).length, 1);
      expect(encodeGeohash(0, 0, precision: 12).length, 12);
    });

    test('rejects out-of-range inputs', () {
      expect(
        () => encodeGeohash(91, 0),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => encodeGeohash(0, 181),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => encodeGeohash(0, 0, precision: 0),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('decodeGeohash', () {
    test('round-trips within cell half-width', () {
      const String hash = 'tek92e';
      final decoded = decodeGeohash(hash)!;
      // The decoded center must be inside the cell — re-encoding it
      // produces the same prefix.
      final String reEncoded = encodeGeohash(decoded.lat, decoded.lng,
          precision: hash.length);
      expect(reEncoded, hash);
    });

    test('returns null for invalid characters', () {
      // '!' is not in the base32 alphabet.
      expect(decodeGeohash('!'), isNull);
    });
  });

  group('neighborPrefixes', () {
    test('returns just the center for a zero-radius query', () {
      final List<String> cells = neighborPrefixes(
        centerLat: 18.52,
        centerLng: 73.85,
        radiusKm: 0,
        precision: 5,
      );
      expect(cells, hasLength(1));
      expect(cells.first, encodeGeohash(18.52, 73.85, precision: 5));
    });

    test('covers a 50 km radius with multiple cells', () {
      final List<String> cells = neighborPrefixes(
        centerLat: 18.52,
        centerLng: 73.85,
        radiusKm: 50,
        precision: 5,
      );
      // 50 km at the equator (~5° lat) needs at least 9 cells.
      expect(cells.length, greaterThanOrEqualTo(9));
      // The center prefix is always included.
      expect(
        cells,
        contains(encodeGeohash(18.52, 73.85, precision: 5)),
      );
    });

    test('a point at the center is always within 0 km of itself', () {
      final List<String> cells = neighborPrefixes(
        centerLat: 51.5074,
        centerLng: -0.1278,
        radiusKm: 5,
        precision: 5,
      );
      final String londonPrefix =
          encodeGeohash(51.5074, -0.1278, precision: 5);
      expect(cells, contains(londonPrefix));
    });
  });
}
