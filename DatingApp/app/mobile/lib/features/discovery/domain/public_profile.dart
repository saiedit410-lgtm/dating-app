import 'package:dating_app/features/profile/domain/profile_enums.dart';
import 'package:dating_app/features/profile/domain/profile_photo.dart';

/// The PUBLIC view of another user's profile — only fields other users are
/// allowed to see. Private data (phone number, exact location, tokens) lives in
/// `users/{uid}/private/*` and is never part of this model.
class PublicProfile {
  const PublicProfile({
    required this.uid,
    this.displayName,
    this.age,
    this.gender,
    this.interestedIn = const <Gender>[],
    this.datingIntent,
    this.bio,
    this.city,
    this.state,
    this.country,
    this.photos = const <ProfilePhoto>[],
    this.isVerified = false,
  });

  /// Builds a [PublicProfile] from a `users/{uid}` document's public fields.
  factory PublicProfile.fromMap(String uid, Map<String, dynamic> data) {
    final List<Gender> interestedIn =
        ((data['interestedIn'] as List<dynamic>?) ?? <dynamic>[])
            .map((dynamic e) => Gender.fromName(e as String?))
            .whereType<Gender>()
            .toList();
    final List<ProfilePhoto> photos =
        ((data['photos'] as List<dynamic>?) ?? <dynamic>[])
            .map(
              (dynamic e) =>
                  ProfilePhoto.fromMap((e as Map).cast<String, dynamic>()),
            )
            .toList();
    return PublicProfile(
      uid: uid,
      displayName: data['displayName'] as String?,
      age: (data['age'] as num?)?.toInt(),
      gender: Gender.fromName(data['gender'] as String?),
      interestedIn: interestedIn,
      datingIntent: DatingIntent.fromName(data['datingIntent'] as String?),
      bio: data['bio'] as String?,
      city: data['city'] as String?,
      state: data['state'] as String?,
      country: data['country'] as String?,
      photos: photos,
      isVerified: data['isVerified'] as bool? ?? false,
    );
  }

  final String uid;
  final String? displayName;
  final int? age;
  final Gender? gender;
  final List<Gender> interestedIn;
  final DatingIntent? datingIntent;
  final String? bio;
  final String? city;
  final String? state;
  final String? country;
  final List<ProfilePhoto> photos;
  final bool isVerified;

  String? get primaryPhotoUrl => photos.isEmpty ? null : photos.first.url;

  /// A short, single-line bio preview for cards.
  String? bioPreview({int maxChars = 80}) {
    final String? text = bio?.trim();
    if (text == null || text.isEmpty) return null;
    if (text.length <= maxChars) return text;
    return '${text.substring(0, maxChars).trimRight()}…';
  }

  /// "City, State" (omitting blank parts).
  String get locationLabel => <String?>[city, state]
      .where((String? s) => s != null && s.trim().isNotEmpty)
      .join(', ');
}
