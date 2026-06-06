import 'package:dating_app/features/matching/domain/match_preferences.dart';

/// Reads/writes per-user [MatchPreferences].
///
/// Persisted at `users/{uid}/private/matchPrefs` (owner + admin
/// only via rules). When the document is missing, callers fall
/// back to [MatchPreferences.defaults] derived from the user's
/// profile.
abstract interface class MatchRepository {
  /// Live [MatchPreferences] for [uid] (null when the document is
  /// missing).
  Stream<MatchPreferences?> watchMatchPreferences(String uid);

  /// One-shot read; same null semantics as [watchMatchPreferences].
  Future<MatchPreferences?> fetchMatchPreferences(String uid);

  /// Persists [prefs] for [uid]. The key-whitelist rule on
  /// `users/{uid}/private/matchPrefs` validates the write server-side.
  Future<void> saveMatchPreferences(String uid, MatchPreferences prefs);
}
