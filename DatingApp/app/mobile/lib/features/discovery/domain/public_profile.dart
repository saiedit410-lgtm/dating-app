import 'package:cloud_firestore/cloud_firestore.dart';
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
    this.geohash,
    this.interests = const <String>[],
    this.lastActiveAt,
    this.completion,
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
    final List<String> interests =
        ((data['interests'] as List<dynamic>?) ?? <dynamic>[])
            .map((dynamic e) => e as String)
            .toList(growable: false);
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
      // Public geohash is what the nearby tab uses to compute distance to
      // this profile. Exact coords never live on this doc.
      geohash: data['geohash'] as String?,
      interests: interests,
      lastActiveAt: (data['lastActiveAt'] is Timestamp)
          ? (data['lastActiveAt'] as Timestamp).toDate()
          : null,
      completion: (data['profileCompletion'] as num?)?.toInt(),
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

  /// Coarse public geohash of the subject (precision 6). Used to compute
  /// the viewer->subject distance in the nearby tab. Exact lat/lng live
  /// on `users/{uid}/private/data` (owner + admin only).
  final String? geohash;

  /// Phase 2.2 — interests used by the matching scorer. Empty for
  /// users who have not set any. Read-only on the public view.
  final List<String> interests;

  /// Phase 2.2 — last user-action timestamp. Drives `f_active`.
  final DateTime? lastActiveAt;

  /// Phase 2.2 — 0..100 profile-completion percentage. Drives
  /// `f_complete`. `null` on documents that pre-date the field.
  final int? completion;

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
