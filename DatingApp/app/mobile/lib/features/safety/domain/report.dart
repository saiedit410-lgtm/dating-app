/// Why a user is being reported.
enum ReportCategory {
  spam,
  fakeProfile,
  harassment,
  inappropriateContent,
  other;

  String get label => switch (this) {
    ReportCategory.spam => 'Spam',
    ReportCategory.fakeProfile => 'Fake profile',
    ReportCategory.harassment => 'Harassment',
    ReportCategory.inappropriateContent => 'Inappropriate content',
    ReportCategory.other => 'Other',
  };

  static ReportCategory? fromName(String? name) {
    for (final ReportCategory c in ReportCategory.values) {
      if (c.name == name) return c;
    }
    return null;
  }
}

/// Moderation lifecycle of a report (read/advanced by admins later).
enum ReportStatus {
  open,
  reviewing,
  actioned,
  dismissed;

  static ReportStatus? fromName(String? name) {
    for (final ReportStatus s in ReportStatus.values) {
      if (s.name == name) return s;
    }
    return null;
  }
}

/// A moderation report (`reports/{reportId}`). Created by users; read/triaged
/// only by admins (Admin SDK / custom claims). Modelled here so the future
/// admin dashboard can deserialize it.
class Report {
  const Report({
    required this.id,
    required this.reporterUid,
    required this.reportedUid,
    required this.category,
    required this.description,
    required this.status,
  });

  factory Report.fromMap(String id, Map<String, dynamic> data) => Report(
    id: id,
    reporterUid: data['reporterUid'] as String? ?? '',
    reportedUid: data['reportedUid'] as String? ?? '',
    category:
        ReportCategory.fromName(data['category'] as String?) ??
        ReportCategory.other,
    description: data['description'] as String? ?? '',
    status: ReportStatus.fromName(data['status'] as String?) ?? ReportStatus.open,
  );

  final String id;
  final String reporterUid;
  final String reportedUid;
  final ReportCategory category;
  final String description;
  final ReportStatus status;
}
