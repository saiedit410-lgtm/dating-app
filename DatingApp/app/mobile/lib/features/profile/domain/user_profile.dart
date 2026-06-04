import 'package:dating_app/features/profile/domain/profile_enums.dart';
import 'package:dating_app/features/profile/domain/profile_photo.dart';

/// The user's profile, stored on the `users/{uid}` document (the same document
/// created at first login). Most fields are nullable because the profile is
/// filled in progressively during onboarding.
class UserProfile {
  const UserProfile({
    required this.uid,
    this.phoneNumber,
    this.displayName,
    this.dateOfBirth,
    this.gender,
    this.interestedIn = const <Gender>[],
    this.datingIntent,
    this.bio,
    this.city,
    this.state,
    this.country,
    this.photos = const <ProfilePhoto>[],
    this.profilePhotoUrls = const <String>[],
    this.profileCompletion = 0,
    this.onboardingComplete = false,
    this.isVerified = false,
    this.accountStatus = 'active',
  });

  final String uid;
  final String? phoneNumber;
  final String? displayName;
  final DateTime? dateOfBirth;
  final Gender? gender;
  final List<Gender> interestedIn;
  final DatingIntent? datingIntent;
  final String? bio;
  final String? city;
  final String? state;
  final String? country;
  /// Rich photo list (id + url + storage path), order = display order;
  /// index 0 is the primary photo.
  final List<ProfilePhoto> photos;
  final List<String> profilePhotoUrls;
  final int profileCompletion;
  final bool onboardingComplete;
  final bool isVerified;
  final String accountStatus;

  /// Age in whole years derived from [dateOfBirth], or null if unset.
  int? get age => dateOfBirth == null ? null : calculateAge(dateOfBirth!);

  /// The primary photo URL (first photo), or null when there are none.
  String? get primaryPhotoUrl => photos.isEmpty ? null : photos.first.url;

  int get photoCount => photos.length;

  /// Whole-year age as of [asOf] (defaults to now).
  static int calculateAge(DateTime dob, {DateTime? asOf}) {
    final DateTime now = asOf ?? DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }
}
