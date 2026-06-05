import 'package:dating_app/features/discovery/domain/user_location.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserLocation.fromLatLng', () {
    test('encodes geohash and builds a prefix ladder', () {
      final loc = UserLocation.fromLatLng(
        latitude: 18.5204,
        longitude: 73.8567,
        updatedAt: DateTime(2026, 6, 6),
      );
      expect(loc.geohash, isNotEmpty);
      expect(loc.geohashPrefixes, isNotEmpty);
      // Each prefix is a strict prefix of the full hash.
      for (final String p in loc.geohashPrefixes) {
        expect(loc.geohash.startsWith(p), isTrue);
      }
      // The longest prefix equals the full geohash.
      expect(loc.geohashPrefixes.last, loc.geohash);
    });

    test('does not expose exact coords on the public read path', () {
      // fromPublicMap has no lat/lng to leak — they are 0,0 placeholders.
      final loc = UserLocation.fromPublicMap(<String, dynamic>{
        'geohash': 'tdr1y6',
        'geohashPrefixes': <String>['tdr', 'tdr1', 'tdr1y'],
      });
      expect(loc.geohash, 'tdr1y6');
      expect(loc.geohashPrefixes, hasLength(3));
      expect(loc.latitude, 0);
      expect(loc.longitude, 0);
    });
  });
}
