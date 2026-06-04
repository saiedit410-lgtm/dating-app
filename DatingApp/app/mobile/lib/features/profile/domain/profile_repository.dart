import 'package:dating_app/features/profile/domain/onboarding_draft.dart';
import 'package:dating_app/features/profile/domain/user_profile.dart';

/// Contract for reading and writing the user's profile document. Implemented in
/// the data layer by Firestore.
abstract interface class ProfileRepository {
  /// Live profile for [uid] (null until the document exists).
  Stream<UserProfile?> watchProfile(String uid);

  /// One-shot read of the profile for [uid].
  Future<UserProfile?> fetchProfile(String uid);

  /// Persists an in-progress [draft] (merge) so onboarding can be resumed.
  /// Sets `profileCompletion` and keeps `onboardingComplete` false.
  Future<void> saveDraft(String uid, OnboardingDraft draft);

  /// Finalises onboarding: writes all fields, `profileCompletion = 100`, and
  /// `onboardingComplete = true`.
  Future<void> submitProfile(String uid, OnboardingDraft draft);
}
