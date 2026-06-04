import 'package:dating_app/features/profile/domain/onboarding_draft.dart';
import 'package:dating_app/features/profile/domain/profile_enums.dart';
import 'package:dating_app/features/profile/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfile.calculateAge', () {
    test('accounts for whether the birthday has occurred this year', () {
      final dob = DateTime(2000, 6, 15);
      expect(
        UserProfile.calculateAge(dob, asOf: DateTime(2026, 6, 14)),
        25,
      );
      expect(
        UserProfile.calculateAge(dob, asOf: DateTime(2026, 6, 15)),
        26,
      );
    });
  });

  group('OnboardingDraft.completion', () {
    test('is 0 for an empty draft and 100 when all steps are filled', () {
      expect(const OnboardingDraft().completion, 0);

      final full = OnboardingDraft(
        displayName: 'Aanya',
        dateOfBirth: DateTime(2000, 1, 1),
        gender: Gender.female,
        interestedIn: const <Gender>[Gender.male],
        datingIntent: DatingIntent.longTerm,
        bio: 'Hello there.',
        city: 'Pune',
        state: 'Maharashtra',
        country: 'India',
      );
      expect(full.completion, 100);
    });
  });

  group('OnboardingDraft.validateStep', () {
    test('step 0 rejects empty name, then under-18, then accepts valid', () {
      expect(const OnboardingDraft().validateStep(0), isNotNull);

      final underage = OnboardingDraft(
        displayName: 'Sam',
        dateOfBirth: DateTime.now(),
        gender: Gender.other,
      );
      expect(underage.validateStep(0), contains('at least'));

      final valid = OnboardingDraft(
        displayName: 'Sam',
        dateOfBirth: DateTime(2000, 1, 1),
        gender: Gender.other,
      );
      expect(valid.validateStep(0), isNull);
    });

    test('step 1 requires interestedIn and a dating intent', () {
      expect(const OnboardingDraft().validateStep(1), isNotNull);
      final valid = const OnboardingDraft(
        interestedIn: <Gender>[Gender.female],
        datingIntent: DatingIntent.casual,
      );
      expect(valid.validateStep(1), isNull);
    });
  });

  group('enum fromName', () {
    test('round-trips known names and returns null otherwise', () {
      expect(Gender.fromName('female'), Gender.female);
      expect(Gender.fromName('unknown'), isNull);
      expect(DatingIntent.fromName('longTerm'), DatingIntent.longTerm);
      expect(DatingIntent.fromName(null), isNull);
    });
  });
}
