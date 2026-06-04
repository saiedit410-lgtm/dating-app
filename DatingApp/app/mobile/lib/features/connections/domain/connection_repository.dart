import 'package:dating_app/features/connections/domain/connection.dart';
import 'package:dating_app/features/connections/domain/friend_request.dart';

/// A page of accepted connections plus an opaque pagination cursor.
class ConnectionPage {
  const ConnectionPage({
    required this.connections,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<Connection> connections;
  final Object? nextCursor;
  final bool hasMore;
}

/// Reads/writes friend requests and connections. References users by uid only —
/// profile data is fetched separately (see PublicProfile) and never duplicated.
abstract interface class ConnectionRepository {
  /// The relationship between [me] and [other].
  Future<RelationshipState> relationshipBetween(String me, String other);

  Future<void> sendRequest({required String fromUid, required String toUid});

  /// Sender cancels their own pending request.
  Future<void> cancelRequest({required String fromUid, required String toUid});

  /// Recipient accepts a pending request (also creates the connection).
  Future<void> acceptRequest({required String fromUid, required String toUid});

  /// Recipient rejects a pending request.
  Future<void> rejectRequest({required String fromUid, required String toUid});

  /// Live list of pending requests addressed to [me] (newest first).
  Stream<List<FriendRequest>> watchIncomingRequests(String me);

  /// Paginated accepted connections for [me] (newest first).
  Future<ConnectionPage> fetchConnections({
    required String me,
    Object? cursor,
    int limit,
  });
}
