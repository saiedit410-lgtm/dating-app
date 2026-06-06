/// Deterministic ids for profile-visitor records.
class VisitorIds {
  const VisitorIds._();

  /// Directional visitor id: `{viewerUid}_{profileUid}`.
  static String visit(String viewerUid, String profileUid) =>
      '${viewerUid}_$profileUid';
}

/// A profile-view (`profileVisitors/{viewerUid}_{profileUid}`).
/// Records that [viewerUid] opened [profileUid]'s profile detail screen.
/// Latest-write-wins on the same pair (Firestore `set(merge: true)`).
class ProfileVisitor {
  const ProfileVisitor({
    required this.id,
    required this.viewerUid,
    required this.profileUid,
    required this.viewedAt,
  });

  factory ProfileVisitor.fromMap(String id, Map<String, dynamic> data) =>
      ProfileVisitor(
        id: id,
        viewerUid: data['viewerUid'] as String? ?? '',
        profileUid: data['profileUid'] as String? ?? '',
        viewedAt: (data['viewedAt'] is DateTime)
            ? data['viewedAt'] as DateTime
            : DateTime.fromMillisecondsSinceEpoch(0),
      );

  final String id;
  final String viewerUid;
  final String profileUid;
  final DateTime viewedAt;
}
