import 'package:dating_app/core/firebase/firebase_providers.dart';
import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/likes/data/firestore_like_repository.dart';
import 'package:dating_app/features/likes/data/firestore_profile_visitor_repository.dart';
import 'package:dating_app/features/likes/domain/like.dart';
import 'package:dating_app/features/likes/domain/like_repository.dart';
import 'package:dating_app/features/likes/domain/profile_visitor.dart';
import 'package:dating_app/features/likes/domain/profile_visitor_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'likes_providers.g.dart';

/// The app's [LikeRepository] (Firestore-backed).
@Riverpod(keepAlive: true)
LikeRepository likeRepository(Ref ref) =>
    FirestoreLikeRepository(ref.watch(firebaseFirestoreProvider));

/// The app's [ProfileVisitorRepository] (Firestore-backed).
@Riverpod(keepAlive: true)
ProfileVisitorRepository profileVisitorRepository(Ref ref) =>
    FirestoreProfileVisitorRepository(ref.watch(firebaseFirestoreProvider));

/// Live likes the signed-in user has sent.
@riverpod
Stream<List<Like>> sentLikes(Ref ref) {
  final String? me = ref.watch(authStateChangesProvider).value?.uid;
  if (me == null) return Stream<List<Like>>.value(<Like>[]);
  return ref.watch(likeRepositoryProvider).watchSentLikes(me);
}

/// Live likes the signed-in user has received.
@riverpod
Stream<List<Like>> receivedLikes(Ref ref) {
  final String? me = ref.watch(authStateChangesProvider).value?.uid;
  if (me == null) return Stream<List<Like>>.value(<Like>[]);
  return ref.watch(likeRepositoryProvider).watchReceivedLikes(me);
}

/// True when the signed-in user has liked [otherUid]. Live.
@riverpod
Stream<bool> hasLikedOther(Ref ref, String otherUid) {
  final String? me = ref.watch(authStateChangesProvider).value?.uid;
  if (me == null || me == otherUid) return Stream<bool>.value(false);
  return ref
      .watch(likeRepositoryProvider)
      .watchSentLikes(me)
      .map((List<Like> sent) => sent.any((Like l) => l.toUid == otherUid));
}

/// Live list of recent visitors to the signed-in user's profile.
@riverpod
Stream<List<ProfileVisitor>> recentVisitors(Ref ref) {
  final String? me = ref.watch(authStateChangesProvider).value?.uid;
  if (me == null) return Stream<List<ProfileVisitor>>.value(<ProfileVisitor>[]);
  return ref.watch(profileVisitorRepositoryProvider).watchRecentVisitors(me);
}
