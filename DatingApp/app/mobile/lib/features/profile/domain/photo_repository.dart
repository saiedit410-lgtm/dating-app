import 'dart:typed_data';

import 'package:dating_app/features/profile/domain/profile_photo.dart';

/// Contract for profile-photo storage + metadata, implemented by Firebase
/// Storage (blobs) + Firestore (metadata) in the data layer.
abstract interface class PhotoRepository {
  /// Uploads [bytes] as a new photo for [uid] and records its metadata.
  /// [contentType] must be an allowed image MIME type.
  Future<ProfilePhoto> addPhoto(
    String uid, {
    required Uint8List bytes,
    required String contentType,
  });

  /// Deletes the photo [photoId] (blob + metadata).
  Future<void> deletePhoto(String uid, String photoId);

  /// Makes [photoId] the primary (first) photo.
  Future<void> setPrimary(String uid, String photoId);

  /// Reorders the photos to match [orderedPhotoIds] (index 0 = primary).
  Future<void> reorderPhotos(String uid, List<String> orderedPhotoIds);
}
