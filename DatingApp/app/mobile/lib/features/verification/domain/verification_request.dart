/// Lifecycle of a verification request.
enum VerificationStatus {
  pending,
  approved,
  rejected;

  static VerificationStatus? fromName(String? name) {
    for (final VerificationStatus s in VerificationStatus.values) {
      if (s.name == name) return s;
    }
    return null;
  }
}

/// A verification request (`verificationRequests/{uid}` — doc id == uid, so a
/// user can only ever have one active request).
class VerificationRequest {
  const VerificationRequest({
    required this.uid,
    required this.status,
    this.selfiePhotoUrl,
    this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
  });

  factory VerificationRequest.fromMap(String id, Map<String, dynamic> data) =>
      VerificationRequest(
        uid: data['uid'] as String? ?? id,
        status:
            VerificationStatus.fromName(data['status'] as String?) ??
            VerificationStatus.pending,
        selfiePhotoUrl: data['selfiePhotoUrl'] as String?,
        submittedAt: _toDate(data['submittedAt']),
        reviewedAt: _toDate(data['reviewedAt']),
        reviewedBy: data['reviewedBy'] as String?,
        rejectionReason: data['rejectionReason'] as String?,
      );

  final String uid;
  final VerificationStatus status;
  final String? selfiePhotoUrl;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;

  bool get isPending => status == VerificationStatus.pending;
  bool get isApproved => status == VerificationStatus.approved;
  bool get isRejected => status == VerificationStatus.rejected;

  /// Whether the user can (re)submit: no request yet, or a rejected one.
  bool get canSubmit => isRejected;

  static DateTime? _toDate(Object? value) {
    if (value == null) return null;
    // Firestore Timestamp without importing the type into the domain.
    try {
      return (value as dynamic).toDate() as DateTime?;
    } catch (_) {
      return null;
    }
  }
}
