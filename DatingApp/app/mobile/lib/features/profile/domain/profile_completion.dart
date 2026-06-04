import 'package:dating_app/features/profile/domain/user_profile.dart';

/// Computes the profile completion percentage across five equally-weighted
/// parts. A profile cannot reach 100% until at least one photo exists.
class ProfileCompletion {
  const ProfileCompletion._();

  static const int totalParts = 5;

  static int fromFlags({
    required bool basics,
    required bool preferences,
    required bool location,
    required bool bio,
    required bool hasPhoto,
  }) {
    final int done = <bool>[
      basics,
      preferences,
      location,
      bio,
      hasPhoto,
    ].where((bool b) => b).length;
    return (done * 100 / totalParts).round();
  }

  static int forProfile(UserProfile profile) {
    bool filled(String? value) => value?.trim().isNotEmpty ?? false;
    return fromFlags(
      basics:
          filled(profile.displayName) &&
          profile.dateOfBirth != null &&
          profile.gender != null,
      preferences:
          profile.interestedIn.isNotEmpty && profile.datingIntent != null,
      location:
          filled(profile.city) &&
          filled(profile.state) &&
          filled(profile.country),
      bio: profile.bio != null,
      hasPhoto: profile.photos.isNotEmpty,
    );
  }
}
