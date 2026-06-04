import 'package:dating_app/features/discovery/domain/public_profile.dart';
import 'package:dating_app/features/profile/domain/profile_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PublicProfile.fromMap', () {
    test('maps public fields and derived getters', () {
      final profile = PublicProfile.fromMap('uid-1', <String, dynamic>{
        'displayName': 'Aanya',
        'age': 24,
        'gender': 'female',
        'interestedIn': <String>['male', 'bogus'],
        'datingIntent': 'longTerm',
        'bio': 'Loves travel.',
        'city': 'Pune',
        'state': 'Maharashtra',
        'country': 'India',
        'isVerified': true,
        'photos': <Map<String, dynamic>>[
          <String, dynamic>{'id': 'p1', 'url': 'http://x/1', 'storagePath': 'a'},
          <String, dynamic>{'id': 'p2', 'url': 'http://x/2', 'storagePath': 'b'},
        ],
      });

      expect(profile.uid, 'uid-1');
      expect(profile.age, 24);
      expect(profile.gender, Gender.female);
      expect(profile.interestedIn, <Gender>[Gender.male]); // 'bogus' dropped
      expect(profile.datingIntent, DatingIntent.longTerm);
      expect(profile.isVerified, isTrue);
      expect(profile.photos.length, 2);
      expect(profile.primaryPhotoUrl, 'http://x/1');
      expect(profile.locationLabel, 'Pune, Maharashtra');
    });

    test('bioPreview truncates long text with an ellipsis', () {
      final profile = PublicProfile.fromMap('u', <String, dynamic>{
        'bio': 'a' * 200,
      });
      final String? preview = profile.bioPreview(maxChars: 80);
      expect(preview, isNotNull);
      expect(preview!.length, lessThanOrEqualTo(81));
      expect(preview.endsWith('…'), isTrue);
    });

    test('handles a near-empty document gracefully', () {
      final profile = PublicProfile.fromMap('u', <String, dynamic>{});
      expect(profile.displayName, isNull);
      expect(profile.photos, isEmpty);
      expect(profile.primaryPhotoUrl, isNull);
      expect(profile.interestedIn, isEmpty);
      expect(profile.locationLabel, isEmpty);
    });
  });
}
