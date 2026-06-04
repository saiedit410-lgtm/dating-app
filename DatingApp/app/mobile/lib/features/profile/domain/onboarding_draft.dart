import 'package:dating_app/features/profile/domain/profile_enums.dart';
import 'package:dating_app/features/profile/domain/user_profile.dart';

/// Mutable-by-copy working set for the onboarding form. Persisted as a draft to
/// Firestore on each step so the user can resume where they left off.
class OnboardingDraft {
  const OnboardingDraft({
    this.displayName,
    this.dateOfBirth,
    this.gender,
    this.interestedIn = const <Gender>[],
    this.datingIntent,
    this.bio,
    this.city,
    this.state,
    this.country,
  });

  factory OnboardingDraft.fromProfile(UserProfile? profile) => OnboardingDraft(
    displayName: profile?.displayName,
    dateOfBirth: profile?.dateOfBirth,
    gender: profile?.gender,
    interestedIn: profile?.interestedIn ?? const <Gender>[],
    datingIntent: profile?.datingIntent,
    bio: profile?.bio,
    city: profile?.city,
    state: profile?.state,
    country: profile?.country,
  );

  static const int maxBioLength = 300;
  static const int minAge = 18;

  final String? displayName;
  final DateTime? dateOfBirth;
  final Gender? gender;
  final List<Gender> interestedIn;
  final DatingIntent? datingIntent;
  final String? bio;
  final String? city;
  final String? state;
  final String? country;

  OnboardingDraft copyWith({
    String? displayName,
    DateTime? dateOfBirth,
    Gender? gender,
    List<Gender>? interestedIn,
    DatingIntent? datingIntent,
    String? bio,
    String? city,
    String? state,
    String? country,
  }) {
    return OnboardingDraft(
      displayName: displayName ?? this.displayName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      interestedIn: interestedIn ?? this.interestedIn,
      datingIntent: datingIntent ?? this.datingIntent,
      bio: bio ?? this.bio,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
    );
  }

  bool get _step1Done =>
      (displayName?.trim().isNotEmpty ?? false) &&
      dateOfBirth != null &&
      gender != null;
  bool get _step2Done => interestedIn.isNotEmpty && datingIntent != null;
  bool get _step3Done =>
      (city?.trim().isNotEmpty ?? false) &&
      (state?.trim().isNotEmpty ?? false) &&
      (country?.trim().isNotEmpty ?? false);
  bool get _step4Done => bio != null;

  /// Completion percentage (0–100) across the four data-entry steps.
  int get completion {
    final int done = <bool>[
      _step1Done,
      _step2Done,
      _step3Done,
      _step4Done,
    ].where((bool b) => b).length;
    return (done * 100 / 4).round();
  }

  /// Returns a user-facing validation error for [step] (0-based), or null.
  String? validateStep(int step) {
    switch (step) {
      case 0:
        final String name = displayName?.trim() ?? '';
        if (name.isEmpty) return 'Please enter your name.';
        if (name.length < 2) return 'Your name is too short.';
        if (name.length > 30) {
          return 'Your name must be 30 characters or fewer.';
        }
        if (dateOfBirth == null) return 'Please select your date of birth.';
        if (UserProfile.calculateAge(dateOfBirth!) < minAge) {
          return 'You must be at least $minAge to use Spark.';
        }
        if (gender == null) return 'Please select your gender.';
        return null;
      case 1:
        if (interestedIn.isEmpty) {
          return "Please choose who you're interested in.";
        }
        if (datingIntent == null) {
          return "Please choose what you're looking for.";
        }
        return null;
      case 2:
        if (city?.trim().isEmpty ?? true) return 'Please enter your city.';
        if (state?.trim().isEmpty ?? true) return 'Please enter your state.';
        if (country?.trim().isEmpty ?? true) {
          return 'Please enter your country.';
        }
        return null;
      case 3:
        if ((bio?.length ?? 0) > maxBioLength) {
          return 'Your bio must be $maxBioLength characters or fewer.';
        }
        return null;
      default:
        return null;
    }
  }
}
