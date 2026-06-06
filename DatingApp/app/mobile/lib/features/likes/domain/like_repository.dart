import 'package:dating_app/features/likes/domain/like.dart';

/// Reads/writes likes (`likes/{fromUid}_{toUid}`).
///
/// Profiles are never duplicated on this collection — only uid
/// references + the creation timestamp. The viewer profile for a
/// like row is resolved separately via `PublicProfile` /
/// `profileByIdProvider`.
abstract interface class LikeRepository {
  /// True when [fromUid] has liked [toUid]. One-shot read.
  Future<bool> hasLiked({required String fromUid, required String toUid});

  /// Live list of likes the signed-in user has **sent** (newest first).
  Stream<List<Like>> watchSentLikes(String me);

  /// Live list of likes the signed-in user has **received**
  /// (newest first).
  Stream<List<Like>> watchReceivedLikes(String me);

  /// Records that [fromUid] liked [toUid]. No-op if already liked
  /// (idempotent on doc id).
  Future<void> like({required String fromUid, required String toUid});

  /// Removes [fromUid]'s like of [toUid]. No-op if no like exists.
  Future<void> unlike({required String fromUid, required String toUid});
}
