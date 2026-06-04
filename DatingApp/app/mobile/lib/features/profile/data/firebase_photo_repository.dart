import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/features/profile/domain/photo_repository.dart';
import 'package:dating_app/features/profile/domain/photo_validation.dart';
import 'package:dating_app/features/profile/domain/profile_completion.dart';
import 'package:dating_app/features/profile/domain/profile_photo.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// [PhotoRepository] backed by Firebase Storage (blobs) + Firestore (metadata
/// on `users/{uid}`). Storage path: `users/{uid}/photos/{photoId}`.
class FirebasePhotoRepository implements PhotoRepository {
  FirebasePhotoRepository(this._storage, this._firestore);

  final FirebaseStorage _storage;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  String _photoPath(String uid, String photoId) =>
      'users/$uid/photos/$photoId';

  @override
  Future<ProfilePhoto> addPhoto(
    String uid, {
    required Uint8List bytes,
    required String contentType,
  }) async {
    final String photoId = DateTime.now().microsecondsSinceEpoch.toString();
    final String path = _photoPath(uid, photoId);
    final Reference ref = _storage.ref(path);

    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    final String url = await ref.getDownloadURL();
    final ProfilePhoto photo = ProfilePhoto(
      id: photoId,
      url: url,
      storagePath: path,
    );

    final bool appended = await _mutatePhotos(uid, (List<ProfilePhoto> photos) {
      if (photos.length >= PhotoConstraints.maxPhotos) return null; // reject
      return <ProfilePhoto>[...photos, photo];
    });

    if (!appended) {
      // Roll back the uploaded blob if the cap was hit between validation and
      // the transaction.
      await ref.delete();
      throw StateError(PhotoRejection.tooMany.message);
    }
    return photo;
  }

  @override
  Future<void> deletePhoto(String uid, String photoId) async {
    String? removedPath;
    await _mutatePhotos(uid, (List<ProfilePhoto> photos) {
      removedPath = photos
          .where((ProfilePhoto p) => p.id == photoId)
          .map((ProfilePhoto p) => p.storagePath)
          .cast<String?>()
          .firstWhere((_) => true, orElse: () => null);
      return photos.where((ProfilePhoto p) => p.id != photoId).toList();
    });
    if (removedPath != null) {
      try {
        await _storage.ref(removedPath).delete();
      } catch (_) {
        // Best-effort: metadata is already gone; orphan blob can be GC'd later.
      }
    }
  }

  @override
  Future<void> setPrimary(String uid, String photoId) =>
      _mutatePhotos(uid, (List<ProfilePhoto> photos) {
        final ProfilePhoto? target = photos
            .where((ProfilePhoto p) => p.id == photoId)
            .cast<ProfilePhoto?>()
            .firstWhere((_) => true, orElse: () => null);
        if (target == null) return photos;
        return <ProfilePhoto>[
          target,
          ...photos.where((ProfilePhoto p) => p.id != photoId),
        ];
      });

  @override
  Future<void> reorderPhotos(String uid, List<String> orderedPhotoIds) =>
      _mutatePhotos(uid, (List<ProfilePhoto> photos) {
        final Map<String, ProfilePhoto> byId = <String, ProfilePhoto>{
          for (final ProfilePhoto p in photos) p.id: p,
        };
        final List<ProfilePhoto> reordered = <ProfilePhoto>[
          for (final String id in orderedPhotoIds)
            if (byId.containsKey(id)) byId[id]!,
        ];
        // Keep any photos not present in the ordering (defensive).
        for (final ProfilePhoto p in photos) {
          if (!orderedPhotoIds.contains(p.id)) reordered.add(p);
        }
        return reordered;
      });

  /// Runs [transform] on the current photo list inside a transaction and writes
  /// back the photos + derived metadata + recomputed completion.
  ///
  /// Returns true if the write happened, false if [transform] returned null
  /// (a rejected mutation).
  Future<bool> _mutatePhotos(
    String uid,
    List<ProfilePhoto>? Function(List<ProfilePhoto> photos) transform,
  ) async {
    final DocumentReference<Map<String, dynamic>> ref = _userDoc(uid);
    return _firestore.runTransaction<bool>((Transaction txn) async {
      final DocumentSnapshot<Map<String, dynamic>> snap = await txn.get(ref);
      final Map<String, dynamic> data = snap.data() ?? <String, dynamic>{};
      final List<ProfilePhoto> current =
          ((data['photos'] as List<dynamic>?) ?? <dynamic>[])
              .map(
                (dynamic e) =>
                    ProfilePhoto.fromMap((e as Map).cast<String, dynamic>()),
              )
              .toList();

      final List<ProfilePhoto>? next = transform(current);
      if (next == null) return false;

      final List<String> urls =
          next.map((ProfilePhoto p) => p.url).toList();
      txn.set(ref, <String, Object?>{
        'photos': next.map((ProfilePhoto p) => p.toMap()).toList(),
        'profilePhotoUrls': urls,
        'primaryPhotoUrl': urls.isEmpty ? null : urls.first,
        'photoCount': next.length,
        'profileCompletion': _completion(data, photoCount: next.length),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    });
  }

  int _completion(Map<String, dynamic> data, {required int photoCount}) {
    bool filled(String key) =>
        (data[key] as String?)?.trim().isNotEmpty ?? false;
    return ProfileCompletion.fromFlags(
      basics:
          filled('displayName') &&
          data['dateOfBirth'] != null &&
          data['gender'] != null,
      preferences:
          ((data['interestedIn'] as List<dynamic>?)?.isNotEmpty ?? false) &&
          data['datingIntent'] != null,
      location: filled('city') && filled('state') && filled('country'),
      bio: data['bio'] != null,
      hasPhoto: photoCount > 0,
    );
  }
}
