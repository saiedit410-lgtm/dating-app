/// Deterministic document ids for likes and profile-visitor records.
class LikeIds {
  const LikeIds._();

  /// Directional like id: `{fromUid}_{toUid}`.
  static String like(String fromUid, String toUid) => '${fromUid}_$toUid';
}

/// A "like" (`likes/{fromUid}_{toUid}`). The act of one user expressing
/// interest in another. Stores only uid references + a creation
/// timestamp — never duplicated profile data.
class Like {
  const Like({
    required this.id,
    required this.fromUid,
    required this.toUid,
    required this.createdAt,
  });

  factory Like.fromMap(String id, Map<String, dynamic> data) => Like(
        id: id,
        fromUid: data['fromUid'] as String? ?? '',
        toUid: data['toUid'] as String? ?? '',
        createdAt:
            (data['createdAt'] is DateTime)
                ? data['createdAt'] as DateTime
                : DateTime.fromMillisecondsSinceEpoch(0),
      );

  final String id;
  final String fromUid;
  final String toUid;
  final DateTime createdAt;
}
