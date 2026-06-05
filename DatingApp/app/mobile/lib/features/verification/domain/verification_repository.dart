import 'dart:typed_data';

import 'package:dating_app/features/verification/domain/verification_request.dart';

/// Reads/writes verification requests. Implemented by Firestore + Storage.
///
/// [approve]/[reject] are the moderation seam for the future admin dashboard —
/// they only succeed for admins (security rules), never for the user
/// themselves.
abstract interface class VerificationRepository {
  /// Live verification request for [uid] (null if none submitted).
  Stream<VerificationRequest?> watchRequest(String uid);

  /// Uploads the selfie and submits/re-submits a pending request.
  Future<void> submit({
    required String uid,
    required Uint8List bytes,
    required String contentType,
  });

  /// Admin: approve [uid]'s request (sets `isVerified = true`).
  Future<void> approve({required String uid, required String reviewedBy});

  /// Admin: reject [uid]'s request with a [reason].
  Future<void> reject({
    required String uid,
    required String reviewedBy,
    required String reason,
  });
}
