import 'package:dating_app/features/discovery/domain/public_profile.dart';
import 'package:dating_app/features/matching/domain/match_filter_outcome.dart';
import 'package:dating_app/features/matching/domain/match_filters.dart';
import 'package:dating_app/features/matching/domain/match_preferences.dart';
import 'package:dating_app/features/profile/domain/profile_enums.dart';
import 'package:flutter_test/flutter_test.dart';

PublicProfile _profile({
  String uid = 'u',
  String? displayName = 'Sam',
  int? age = 25,
  Gender? gender = Gender.male,
  List<Gender> interestedIn = const <Gender>[Gender.female],
  DatingIntent? datingIntent = DatingIntent.longTerm,
  bool isVerified = false,
}) => PublicProfile(
      uid: uid,
      displayName: displayName,
      age: age,
      gender: gender,
      interestedIn: interestedIn,
      datingIntent: datingIntent,
      isVerified: isVerified,
    );

void main() {
  const filters = MatchFilters();

  group('MatchFilters.apply — happy path', () {
    test('returns Keep when all four filters pass', () {
      final outcome = filters.apply(
        viewerUid: 'me',
        subject: _profile(uid: 'them'),
        blockedUids: const <String>{},
        viewerPrefs: MatchPreferences.defaults(null),
      );
      expect(outcome, isA<Keep>());
    });
  });

  group('MatchFilters.apply — fail-closed reasons', () {
    test('self', () {
      final outcome = filters.apply(
        viewerUid: 'me',
        subject: _profile(uid: 'me'),
        blockedUids: const <String>{},
        viewerPrefs: MatchPreferences.defaults(null),
      );
      expect((outcome as Exclude).reason, 'self');
    });

    test('blocked', () {
      final outcome = filters.apply(
        viewerUid: 'me',
        subject: _profile(uid: 'them'),
        blockedUids: const <String>{'them'},
        viewerPrefs: MatchPreferences.defaults(null),
      );
      expect((outcome as Exclude).reason, 'blocked');
    });

    test('incomplete_profile (no display name)', () {
      final outcome = filters.apply(
        viewerUid: 'me',
        subject: _profile(displayName: null),
        blockedUids: const <String>{},
        viewerPrefs: MatchPreferences.defaults(null),
      );
      expect((outcome as Exclude).reason, 'incomplete_profile');
    });

    test('incomplete_profile (no age)', () {
      final outcome = filters.apply(
        viewerUid: 'me',
        subject: _profile(age: null),
        blockedUids: const <String>{},
        viewerPrefs: MatchPreferences.defaults(null),
      );
      expect((outcome as Exclude).reason, 'incomplete_profile');
    });

    test('intent_mismatch when requireIntentMatch is on and below floor', () {
      const prefs = MatchPreferences(
        otherAgeMin: 18,
        otherAgeMax: 99,
        requiredGenders: <Gender>[],
        requireIntentMatch: true,
        intentMatrixFloor: 0.4,
      );
      final outcome = filters.apply(
        viewerUid: 'me',
        subject: _profile(datingIntent: DatingIntent.friendship),
        blockedUids: const <String>{},
        viewerPrefs: prefs,
        viewerIntent: DatingIntent.longTerm, // 0.2 < 0.4
      );
      expect((outcome as Exclude).reason, 'intent_mismatch');
    });

    test('intent-compatible when above the floor', () {
      const prefs = MatchPreferences(
        otherAgeMin: 18,
        otherAgeMax: 99,
        requiredGenders: <Gender>[],
        requireIntentMatch: true,
        intentMatrixFloor: 0.4,
      );
      final outcome = filters.apply(
        viewerUid: 'me',
        subject: _profile(datingIntent: DatingIntent.casual),
        blockedUids: const <String>{},
        viewerPrefs: prefs,
        viewerIntent: DatingIntent.longTerm, // 0.4 >= 0.4
      );
      expect(outcome, isA<Keep>());
    });

    test('intent-strict off by default — no rejection', () {
      final outcome = filters.apply(
        viewerUid: 'me',
        subject: _profile(datingIntent: DatingIntent.friendship),
        blockedUids: const <String>{},
        viewerPrefs: MatchPreferences.defaults(null), // requireIntentMatch=false
        viewerIntent: DatingIntent.longTerm,
      );
      expect(outcome, isA<Keep>());
    });
  });
}
