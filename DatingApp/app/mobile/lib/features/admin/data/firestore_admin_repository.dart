import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dating_app/features/admin/domain/admin_action.dart';
import 'package:dating_app/features/admin/domain/admin_repository.dart';
import 'package:dating_app/features/admin/domain/report_resolution.dart';
import 'package:dating_app/features/admin/domain/user_status.dart';
import 'package:dating_app/features/safety/domain/report.dart';
import 'package:dating_app/features/verification/domain/verification_request.dart';

/// Firestore + Cloud Functions implementation of [AdminRepository].
///
/// Reads go straight to Firestore (the rules already gate them to
/// `isAdmin()`). Writes go through the four admin callables — the
/// rules deny direct client writes on the trust/status fields, so
/// every privileged mutation MUST hit the function.
class FirestoreAdminRepository implements AdminRepository {
  FirestoreAdminRepository(this._firestore, this._functions);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> get _verifications =>
      _firestore.collection('verificationRequests');
  CollectionReference<Map<String, dynamic>> get _reports =>
      _firestore.collection('reports');
  CollectionReference<Map<String, dynamic>> get _adminActions =>
      _firestore.collection('adminActions');

  @override
  Stream<List<VerificationRequest>> watchPendingVerifications() =>
      _verifications
          .where('status', isEqualTo: 'pending')
          .orderBy('submittedAt')
          .snapshots()
          .map(
            (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
                .map(
                  (QueryDocumentSnapshot<Map<String, dynamic>> d) =>
                      VerificationRequest.fromMap(d.id, d.data()),
                )
                .toList(),
          );

  @override
  Stream<List<Report>> watchOpenReports() => _reports
      .where('status', isEqualTo: 'open')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> d) =>
                  Report.fromMap(d.id, d.data()),
            )
            .toList(),
      );

  @override
  Stream<List<AdminAction>> watchAuditLog({int limit = 100}) =>
      _adminActions
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map(
            (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
                .map(
                  (QueryDocumentSnapshot<Map<String, dynamic>> d) =>
                      AdminAction.fromMap(d.id, d.data()),
                )
                .toList(),
          );

  @override
  Future<void> approveVerification({required String uid}) =>
      _functions.httpsCallable('approveVerification').call(<String, dynamic>{
        'uid': uid,
      });

  @override
  Future<void> rejectVerification({
    required String uid,
    required String reason,
  }) =>
      _functions.httpsCallable('rejectVerification').call(<String, dynamic>{
        'uid': uid,
        'reason': reason,
      });

  @override
  Future<void> resolveReport({
    required String reportId,
    required ReportResolution resolution,
    String? note,
  }) =>
      _functions.httpsCallable('resolveReport').call(<String, dynamic>{
        'reportId': reportId,
        'resolution': resolution.name,
        if (note != null && note.isNotEmpty) 'note': note,
      });

  @override
  Future<void> setUserStatus({
    required String uid,
    required UserStatus status,
    String? note,
  }) =>
      _functions.httpsCallable('setUserStatus').call(<String, dynamic>{
        'uid': uid,
        // The function expects 'active' | 'suspended' | 'banned'. For the
        // client-side 'unknown' state we fall back to 'active' (no-op) —
        // the admin UI never invokes this for `UserStatus.unknown`.
        'status': _wireStatus(status),
        if (note != null && note.isNotEmpty) 'note': note,
      });

  String _wireStatus(UserStatus s) {
    switch (s) {
      case UserStatus.active:
        return 'active';
      case UserStatus.suspended:
        return 'suspended';
      case UserStatus.banned:
        return 'banned';
      case UserStatus.unknown:
        // Defensive: the admin UI never sends this. The Cloud Function
        // would reject 'unknown' with `invalid-argument` if it ever did.
        return 'active';
    }
  }
}
