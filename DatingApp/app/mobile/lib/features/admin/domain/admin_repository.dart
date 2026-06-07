import 'package:dating_app/features/admin/domain/admin_action.dart';
import 'package:dating_app/features/admin/domain/report_resolution.dart';
import 'package:dating_app/features/admin/domain/user_status.dart';
import 'package:dating_app/features/safety/domain/report.dart';
import 'package:dating_app/features/verification/domain/verification_request.dart';

/// Admin-side reads (Firestore) + privileged-mutation callables
/// (Cloud Functions).
///
/// The two read streams are live. The mutation methods map 1:1 to
/// the four callables exported by `backend/functions/src/admin/helpers.ts`:
///   * `approveVerification`           -> approveVerification
///   * `rejectVerification`            -> rejectVerification
///   * `resolveReport`                 -> resolveReport
///   * `setUserStatus`                 -> setUserStatus
///
/// Every mutation is gated server-side by `requireAdmin(context)` and
/// writes an `adminActions/{auto}` row before/after the privileged
/// mutation. The audit read stream is the read side of that loop.
abstract interface class AdminRepository {
  /// Live stream of `verificationRequests where status == 'pending'`,
  /// FIFO by `submittedAt`. Backed by the existing
  /// `(status ASC, submittedAt ASC)` index — no new index needed.
  Stream<List<VerificationRequest>> watchPendingVerifications();

  /// Live stream of `reports where status == 'open'`, newest first.
  /// Backed by the new `(status ASC, createdAt DESC)` index.
  Stream<List<Report>> watchOpenReports();

  /// Live stream of the audit log, newest first. Capped at [limit].
  Stream<List<AdminAction>> watchAuditLog({int limit = 100});

  /// Approve a pending verification. Cloud Function `approveVerification`.
  /// The function is the only writer of `isVerified` / `verifiedAt`.
  Future<void> approveVerification({required String uid});

  /// Reject a pending verification with [reason]. Cloud Function
  /// `rejectVerification`.
  Future<void> rejectVerification({
    required String uid,
    required String reason,
  });

  /// Resolve an open report. Cloud Function `resolveReport`. When
  /// [resolution] is `suspend` or `ban`, the function also writes
  /// `accountStatus` on the target user and emits a second audit row.
  Future<void> resolveReport({
    required String reportId,
    required ReportResolution resolution,
    String? note,
  });

  /// Set the target user's `accountStatus`. Cloud Function
  /// `setUserStatus`. Used directly by the user-detail screen
  /// (Suspend / Restore) and indirectly by the suspend/ban cascade
  /// from `resolveReport`.
  Future<void> setUserStatus({
    required String uid,
    required UserStatus status,
    String? note,
  });
}
