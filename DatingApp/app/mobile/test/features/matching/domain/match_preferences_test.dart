import 'package:dating_app/features/matching/domain/match_preferences.dart';
import 'package:dating_app/features/profile/domain/profile_enums.dart';
import 'package:dating_app/features/profile/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MatchPreferences.defaults', () {
    test('null profile → open to all, age 18-99, intent-matrix floor 0.4', () {
      final prefs = MatchPreferences.defaults(null);
      expect(prefs.otherAgeMin, 18);
      expect(prefs.otherAgeMax, 99);
      expect(prefs.requiredGenders, isEmpty);
      expect(prefs.requireIntentMatch, isFalse);
      expect(prefs.intentMatrixFloor, 0.4);
    });

    test('profile with interestedIn → that becomes requiredGenders', () {
      final profile = UserProfile(
        uid: 'me',
        interestedIn: const <Gender>[Gender.female, Gender.nonBinary],
      );
      final prefs = MatchPreferences.defaults(profile);
      expect(prefs.requiredGenders,
          <Gender>[Gender.female, Gender.nonBinary]);
    });
  });

  group('MatchPreferences.fromMap / toMap', () {
    test('round-trips a populated value', () {
      const original = MatchPreferences(
        otherAgeMin: 21,
        otherAgeMax: 35,
        requiredGenders: <Gender>[Gender.female],
        requireIntentMatch: true,
        intentMatrixFloor: 0.5,
      );
      final restored = MatchPreferences.fromMap(original.toMap());
      expect(restored.otherAgeMin, original.otherAgeMin);
      expect(restored.otherAgeMax, original.otherAgeMax);
      expect(restored.requiredGenders, original.requiredGenders);
      expect(restored.requireIntentMatch, original.requireIntentMatch);
      expect(restored.intentMatrixFloor, original.intentMatrixFloor);
    });

    test('null map → permissive defaults', () {
      final prefs = MatchPreferences.fromMap(null);
      expect(prefs.otherAgeMin, 18);
      expect(prefs.otherAgeMax, 99);
      expect(prefs.intentMatrixFloor, 0.4);
    });

    test('missing keys fall back to defaults (forward-compat)', () {
      final prefs = MatchPreferences.fromMap(<String, dynamic>{
        'otherAgeMin': 25,
      });
      expect(prefs.otherAgeMin, 25);
      expect(prefs.otherAgeMax, 99);
      expect(prefs.requiredGenders, isEmpty);
    });

    test('unknown gender strings are dropped', () {
      final prefs = MatchPreferences.fromMap(<String, dynamic>{
        'requiredGenders': <String>['female', 'martian'],
      });
      expect(prefs.requiredGenders, <Gender>[Gender.female]);
    });
  });

  group('MatchPreferences.copyWith', () {
    test('patches a single field', () {
      const base = MatchPreferences(
        otherAgeMin: 18,
        otherAgeMax: 99,
        requiredGenders: <Gender>[],
        requireIntentMatch: false,
        intentMatrixFloor: 0.4,
      );
      final patched = base.copyWith(requireIntentMatch: true);
      expect(patched.requireIntentMatch, isTrue);
      expect(patched.otherAgeMin, 18); // unchanged
    });
  });

  group('MatchPreferences == and hashCode', () {
    test('equal value objects compare equal', () {
      const a = MatchPreferences(
        otherAgeMin: 21,
        otherAgeMax: 35,
        requiredGenders: <Gender>[Gender.female],
        requireIntentMatch: false,
        intentMatrixFloor: 0.4,
      );
      const b = MatchPreferences(
        otherAgeMin: 21,
        otherAgeMax: 35,
        requiredGenders: <Gender>[Gender.female],
        requireIntentMatch: false,
        intentMatrixFloor: 0.4,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
