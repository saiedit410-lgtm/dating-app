import 'package:dating_app/core/firebase/firebase_providers.dart';
import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/matching/data/firestore_match_repository.dart';
import 'package:dating_app/features/matching/domain/match_preferences.dart';
import 'package:dating_app/features/matching/domain/match_repository.dart';
import 'package:dating_app/features/matching/domain/match_scorer.dart';
import 'package:dating_app/features/profile/application/profile_providers.dart';
import 'package:dating_app/features/profile/domain/user_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'matching_providers.g.dart';

/// The app's [MatchRepository] (Firestore-backed).
@Riverpod(keepAlive: true)
MatchRepository matchRepository(Ref ref) =>
    FirestoreMatchRepository(ref.watch(firebaseFirestoreProvider));

/// The pure-Dart scoring function. Stateless; one instance for the
/// whole app.
@Riverpod(keepAlive: true)
MatchScorer matchScorer(Ref ref) => const MatchScorer();

/// The signed-in user's [MatchPreferences], streamed from
/// `users/{uid}/private/matchPrefs`. Falls back to a default derived
/// from the user's profile when the document is missing.
@riverpod
Stream<MatchPreferences> currentMatchPreferences(Ref ref) {
  final String? me = ref.watch(authStateChangesProvider).value?.uid;
  if (me == null) {
    return Stream<MatchPreferences>.value(
      MatchPreferences.defaults(null),
    );
  }
  return ref.watch(matchRepositoryProvider).watchMatchPreferences(me).map(
        (MatchPreferences? prefs) => prefs ?? MatchPreferences.defaults(null),
      );
}

/// Aggregated [ViewerContext] for the scorer. Built once per
/// viewer change so controllers don't refetch on profile change
/// without an explicit re-rank call.
@riverpod
ViewerContext viewerContext(Ref ref) {
  final auth = ref.watch(authStateChangesProvider).value;
  final UserProfile? p = ref.watch(currentUserProfileProvider).value;
  return ViewerContext(
    uid: auth?.uid ?? '',
    datingIntent: p?.datingIntent,
    interests: p?.interests ?? const <String>[],
  );
}
