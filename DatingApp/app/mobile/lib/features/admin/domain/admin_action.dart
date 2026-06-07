/// What kind of privileged action this audit row represents. The wire
/// format is the stable string the Cloud Function writes (and the rules
/// + storage allow free-form here — it's just a log).
enum AdminActionType {
  verificationApprove,
  verificationReject,
  reportResolve,
  userSetStatus;

  /// Stable wire-format string used in `adminActions.action`.
  String get wire {
    switch (this) {
      case AdminActionType.verificationApprove:
        return 'verification.approve';
      case AdminActionType.verificationReject:
        return 'verification.reject';
      case AdminActionType.reportResolve:
        return 'report.resolve';
      case AdminActionType.userSetStatus:
        return 'user.setStatus';
    }
  }

  /// Reverse of [wire]. Tolerant of unknown values: returns `null`
  /// for any string the function hasn't shipped.
  static AdminActionType? fromWire(String? wire) {
    switch (wire) {
      case 'verification.approve':
        return AdminActionType.verificationApprove;
      case 'verification.reject':
        return AdminActionType.verificationReject;
      case 'report.resolve':
        return AdminActionType.reportResolve;
      case 'user.setStatus':
        return AdminActionType.userSetStatus;
    }
    return null;
  }
}

enum AdminActionTarget { user, report, verificationRequest }

/// A single row of the `adminActions` collection. Written by the
/// Cloud Function; read by the admin UI's audit log. The doc is
/// append-only and tamper-evident (rules deny client writes).
class AdminAction {
  const AdminAction({
    required this.id,
    required this.adminUid,
    required this.action,
    required this.targetType,
    required this.targetUid,
    required this.payload,
    required this.note,
    required this.createdAt,
  });

  factory AdminAction.fromMap(String id, Map<String, dynamic> data) {
    final DateTime created;
    final Object? rawCreated = data['createdAt'];
    if (rawCreated is DateTime) {
      created = rawCreated;
    } else {
      created = DateTime.fromMillisecondsSinceEpoch(0);
    }
    return AdminAction(
      id: id,
      adminUid: data['adminUid'] as String? ?? '',
      action: AdminActionType.fromWire(data['action'] as String?) ??
          AdminActionType.reportResolve,
      targetType: _targetTypeFromString(data['targetType'] as String?),
      targetUid: data['targetUid'] as String? ?? '',
      payload: (data['payload'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{},
      note: data['note'] as String? ?? '',
      createdAt: created,
    );
  }

  final String id;
  final String adminUid;
  final AdminActionType action;
  final AdminActionTarget targetType;
  final String targetUid;
  final Map<String, dynamic> payload;
  final String note;
  final DateTime createdAt;

  static AdminActionTarget _targetTypeFromString(String? raw) {
    switch (raw) {
      case 'user':
        return AdminActionTarget.user;
      case 'report':
        return AdminActionTarget.report;
      case 'verificationRequest':
        return AdminActionTarget.verificationRequest;
    }
    return AdminActionTarget.user;
  }
}
