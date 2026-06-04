import 'package:dating_app/core/firebase/firebase_providers.dart';
import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/connections/data/firestore_connection_repository.dart';
import 'package:dating_app/features/connections/domain/connection_repository.dart';
import 'package:dating_app/features/connections/domain/friend_request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connection_providers.g.dart';

/// The app's [ConnectionRepository] (Firestore-backed).
@Riverpod(keepAlive: true)
ConnectionRepository connectionRepository(Ref ref) =>
    FirestoreConnectionRepository(ref.watch(firebaseFirestoreProvider));

/// Current relationship between the signed-in user and [otherUid]. Invalidate
/// after an action to refresh the action button.
@riverpod
Future<RelationshipState> relationship(Ref ref, String otherUid) async {
  final String? me = ref.watch(authStateChangesProvider).value?.uid;
  if (me == null || me == otherUid) return RelationshipState.notConnected;
  return ref.watch(connectionRepositoryProvider).relationshipBetween(
    me,
    otherUid,
  );
}

/// Live pending requests addressed to the signed-in user.
@riverpod
Stream<List<FriendRequest>> incomingRequests(Ref ref) {
  final String? me = ref.watch(authStateChangesProvider).value?.uid;
  if (me == null) return Stream<List<FriendRequest>>.value(<FriendRequest>[]);
  return ref.watch(connectionRepositoryProvider).watchIncomingRequests(me);
}
