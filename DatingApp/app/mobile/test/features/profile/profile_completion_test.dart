import 'package:dating_app/features/profile/domain/profile_completion.dart';
import 'package:dating_app/features/profile/domain/profile_enums.dart';
import 'package:dating_app/features/profile/domain/profile_photo.dart';
import 'package:dating_app/features/profile/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileCompletion', () {
    test('all four data steps without a photo tops out at 80%', () {
      expect(
        ProfileCompletion.fromFlags(
          basics: true,
          preferences: true,
          location: true,
          bio: true,
          hasPhoto: false,
        ),
        80,
      );
    });

    test('reaches 100% only once a photo is added', () {
      expect(
        ProfileCompletion.fromFlags(
          basics: true,
          preferences: true,
          location: true,
          bio: true,
          hasPhoto: true,
        ),
        100,
      );
    });

    test('forProfile counts photos as a part', () {
      final base = UserProfile(
        uid: 'u',
        displayName: 'Aanya',
        dateOfBirth: DateTime(2000, 1, 1),
        gender: Gender.female,
        interestedIn: const <Gender>[Gender.male],
        datingIntent: DatingIntent.longTerm,
        bio: 'hi',
        city: 'Pune',
        state: 'MH',
        country: 'India',
      );
      expect(ProfileCompletion.forProfile(base), 80);

      final withPhoto = UserProfile(
        uid: base.uid,
        displayName: base.displayName,
        dateOfBirth: base.dateOfBirth,
        gender: base.gender,
        interestedIn: base.interestedIn,
        datingIntent: base.datingIntent,
        bio: base.bio,
        city: base.city,
        state: base.state,
        country: base.country,
        photos: const <ProfilePhoto>[
          ProfilePhoto(id: '1', url: 'u', storagePath: 'p'),
        ],
      );
      expect(ProfileCompletion.forProfile(withPhoto), 100);
    });
  });
}
