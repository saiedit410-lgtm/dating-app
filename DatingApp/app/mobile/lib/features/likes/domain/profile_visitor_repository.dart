import 'package:dating_app/features/likes/domain/profile_visitor.dart';

/// Reads/writes profile-view records
/// (`profileVisitors/{viewerUid}_{profileUid}`).
///
/// Records that someone opened another user's profile. The viewer
/// owns the write (only they can stamp their own visit); only the
/// profile owner can read the list of who viewed them.
abstract interface class ProfileVisitorRepository {
  /// Records a profile view. Idempotent on doc id — the same
  /// (viewer, profile) pair overwrites with a fresh [viewedAt].
  Future<void> recordView({
    required String viewerUid,
    required String profileUid,
  });

  /// Live list of recent visitors to [me]'s profile (newest first).
  /// The watcher is limited to keep costs bounded.
  Stream<List<ProfileVisitor>> watchRecentVisitors(String me);
}
