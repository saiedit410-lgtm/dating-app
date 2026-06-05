import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/features/verification/domain/verification_repository.dart';
import 'package:dating_app/features/verification/domain/verification_request.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Firestore (`verificationRequests/{uid}`) + Storage
/// (`users/{uid}/verification/{uid}`) implementation.
class FirestoreVerificationRepository implements VerificationRepository {
  FirestoreVerificationRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  DocumentReference<Map<String, dynamic>> _request(String uid) =>
      _firestore.collection('verificationRequests').doc(uid);

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _firestore.collection('users').doc(uid);

  String _selfiePath(String uid) => 'users/$uid/verification/$uid';

  @override
  Stream<VerificationRequest?> watchRequest(String uid) =>
      _request(uid).snapshots().map((
        DocumentSnapshot<Map<String, dynamic>> snap,
      ) {
        final Map<String, dynamic>? data = snap.data();
        if (!snap.exists || data == null) return null;
        return VerificationRequest.fromMap(snap.id, data);
      });

  @override
  Future<void> submit({
    required String uid,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final Reference ref = _storage.ref(_selfiePath(uid));
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    final String url = await ref.getDownloadURL();

    final WriteBatch batch = _firestore.batch();
    batch.set(_request(uid), <String, Object?>{
      'uid': uid,
      'status': VerificationStatus.pending.name,
      'selfiePhotoUrl': url,
      'submittedAt': FieldValue.serverTimestamp(),
      'reviewedAt': null,
      'reviewedBy': null,
      'rejectionReason': null,
    });
    // Reflect "pending" on the public profile (isVerified stays false).
    batch.set(_user(uid), <String, Object?>{
      'verificationStatus': VerificationStatus.pending.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();
  }

  @override
  Future<void> approve({
    required String uid,
    required String reviewedBy,
  }) async {
    final WriteBatch batch = _firestore.batch();
    batch.update(_request(uid), <String, Object?>{
      'status': VerificationStatus.approved.name,
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': reviewedBy,
    });
    batch.set(_user(uid), <String, Object?>{
      'isVerified': true,
      'verificationStatus': VerificationStatus.approved.name,
      'verifiedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();
  }

  @override
  Future<void> reject({
    required String uid,
    required String reviewedBy,
    required String reason,
  }) async {
    final WriteBatch batch = _firestore.batch();
    batch.update(_request(uid), <String, Object?>{
      'status': VerificationStatus.rejected.name,
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': reviewedBy,
      'rejectionReason': reason,
    });
    batch.set(_user(uid), <String, Object?>{
      'verificationStatus': VerificationStatus.rejected.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();
  }
}
