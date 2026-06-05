import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/features/profile/domain/onboarding_draft.dart';
import 'package:dating_app/features/profile/domain/profile_completion.dart';
import 'package:dating_app/features/profile/domain/profile_enums.dart';
import 'package:dating_app/features/profile/domain/profile_photo.dart';
import 'package:dating_app/features/profile/domain/profile_repository.dart';
import 'package:dating_app/features/profile/domain/user_profile.dart';

/// Firestore-backed [ProfileRepository] operating on `users/{uid}`.
class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection('users').doc(uid);

  @override
  Stream<UserProfile?> watchProfile(String uid) =>
      _doc(uid).snapshots().map(_fromSnapshot);

  @override
  Future<UserProfile?> fetchProfile(String uid) async =>
      _fromSnapshot(await _doc(uid).get());

  @override
  Future<void> saveDraft(String uid, OnboardingDraft draft) =>
      _doc(uid).set(_toMap(draft, complete: false), SetOptions(merge: true));

  @override
  Future<void> submitProfile(String uid, OnboardingDraft draft) =>
      _doc(uid).set(_toMap(draft, complete: true), SetOptions(merge: true));

  UserProfile? _fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final Map<String, dynamic>? data = snapshot.data();
    if (!snapshot.exists || data == null) return null;

    final List<Gender> interestedIn = ((data['interestedIn'] as List<dynamic>?) ?? <dynamic>[])
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

    return UserProfile(
      uid: snapshot.id,
      phoneNumber: data['phoneNumber'] as String?,
      photos: photos,
      displayName: data['displayName'] as String?,
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      gender: Gender.fromName(data['gender'] as String?),
      interestedIn: interestedIn,
      datingIntent: DatingIntent.fromName(data['datingIntent'] as String?),
      bio: data['bio'] as String?,
      city: data['city'] as String?,
      state: data['state'] as String?,
      country: data['country'] as String?,
      profilePhotoUrls: ((data['profilePhotoUrls'] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic e) => e as String)
          .toList(),
      profileCompletion: (data['profileCompletion'] as num?)?.toInt() ?? 0,
      onboardingComplete: data['onboardingComplete'] as bool? ?? false,
      isVerified: data['isVerified'] as bool? ?? false,
      verificationStatus: data['verificationStatus'] as String?,
      verifiedAt: (data['verifiedAt'] as Timestamp?)?.toDate(),
      accountStatus: data['accountStatus'] as String? ?? 'active',
    );
  }

  Map<String, Object?> _toMap(OnboardingDraft draft, {required bool complete}) {
    final DateTime? dob = draft.dateOfBirth;
    return <String, Object?>{
      if (draft.displayName != null) 'displayName': draft.displayName!.trim(),
      if (dob != null) 'dateOfBirth': Timestamp.fromDate(dob),
      if (dob != null) 'age': UserProfile.calculateAge(dob),
      if (draft.gender != null) 'gender': draft.gender!.name,
      'interestedIn': draft.interestedIn.map((Gender g) => g.name).toList(),
      if (draft.datingIntent != null) 'datingIntent': draft.datingIntent!.name,
      if (draft.bio != null) 'bio': draft.bio!.trim(),
      if (draft.city != null) 'city': draft.city!.trim(),
      if (draft.state != null) 'state': draft.state!.trim(),
      if (draft.country != null) 'country': draft.country!.trim(),
      // 5-part completion; photos are managed separately, so onboarding alone
      // tops out at 80% until at least one photo is added.
      'profileCompletion': ProfileCompletion.fromFlags(
        basics: draft.validateStep(0) == null,
        preferences: draft.validateStep(1) == null,
        location: draft.validateStep(2) == null,
        bio: draft.bio != null,
        hasPhoto: false,
      ),
      'onboardingComplete': complete,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
