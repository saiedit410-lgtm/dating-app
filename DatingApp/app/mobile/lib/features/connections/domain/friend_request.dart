/// Lifecycle of a friend request.
enum RequestStatus {
  pending,
  accepted,
  rejected,
  cancelled;

  static RequestStatus? fromName(String? name) {
    for (final RequestStatus s in RequestStatus.values) {
      if (s.name == name) return s;
    }
    return null;
  }
}

/// The relationship between the current user and another user, used to drive
/// the discovery / profile-detail action button.
enum RelationshipState {
  notConnected,
  requestSent,
  requestReceived,
  connected,
}

/// A friend request document (`friendRequests/{fromUid}_{toUid}`). Stores only
/// uid references + status — never duplicated profile data.
class FriendRequest {
  const FriendRequest({
    required this.id,
    required this.fromUid,
    required this.toUid,
    required this.status,
  });

  factory FriendRequest.fromMap(String id, Map<String, dynamic> data) =>
      FriendRequest(
        id: id,
        fromUid: data['fromUid'] as String? ?? '',
        toUid: data['toUid'] as String? ?? '',
        status:
            RequestStatus.fromName(data['status'] as String?) ??
            RequestStatus.pending,
      );

  final String id;
  final String fromUid;
  final String toUid;
  final RequestStatus status;
}
