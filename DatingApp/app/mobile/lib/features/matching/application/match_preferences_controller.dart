import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/matching/application/matching_providers.dart';
import 'package:dating_app/features/matching/domain/match_preferences.dart';
import 'package:dating_app/features/profile/application/profile_providers.dart';
import 'package:dating_app/features/profile/domain/profile_enums.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'match_preferences_controller.g.dart';

/// Owns the [MatchPreferences] edit surface. Reads from
/// [currentMatchPreferencesProvider] on build, mutates via
/// [replace] for dirty-tracking, and [save] to persist. The
/// presentation sheet is built on top of this.
@Riverpod(keepAlive: true)
class MatchPreferencesController extends _$MatchPreferencesController {
  @override
  MatchPreferences build() {
    // Seed from the streamed prefs; the stream continues to feed
    // updates while the sheet is open so external edits flow through.
    final MatchPreferences initial =
        ref.watch(currentMatchPreferencesProvider).maybeWhen(
              data: (MatchPreferences p) => p,
              orElse: () => MatchPreferences.defaults(
                ref.read(currentUserProfileProvider).value,
              ),
            );
    return initial;
  }

  /// Replaces the working copy with [prefs]. No persistence.
  void replace(MatchPreferences prefs) {
    state = prefs;
  }

  /// Patches a single field. No persistence.
  void patch({
    int? otherAgeMin,
    int? otherAgeMax,
    bool? requireIntentMatch,
    double? intentMatrixFloor,
    List<Gender>? requiredGenders,
  }) {
    state = state.copyWith(
      otherAgeMin: otherAgeMin,
      otherAgeMax: otherAgeMax,
      requireIntentMatch: requireIntentMatch,
      intentMatrixFloor: intentMatrixFloor,
      requiredGenders: requiredGenders,
    );
  }

  /// Persists the current working copy. No-op when signed out.
  Future<void> save() async {
    final String? uid = ref.read(authStateChangesProvider).value?.uid;
    if (uid == null) return;
    await ref.read(matchRepositoryProvider).saveMatchPreferences(uid, state);
  }
}
