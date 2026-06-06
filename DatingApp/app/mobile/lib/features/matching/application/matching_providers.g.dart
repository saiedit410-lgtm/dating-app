// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'matching_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's [MatchRepository] (Firestore-backed).

@ProviderFor(matchRepository)
final matchRepositoryProvider = MatchRepositoryProvider._();

/// The app's [MatchRepository] (Firestore-backed).

final class MatchRepositoryProvider
    extends
        $FunctionalProvider<MatchRepository, MatchRepository, MatchRepository>
    with $Provider<MatchRepository> {
  /// The app's [MatchRepository] (Firestore-backed).
  MatchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'matchRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$matchRepositoryHash();

  @$internal
  @override
  $ProviderElement<MatchRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MatchRepository create(Ref ref) {
    return matchRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MatchRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MatchRepository>(value),
    );
  }
}

String _$matchRepositoryHash() => r'3f4f494cb71a042787a5797515b2c53a5435f300';

/// The pure-Dart scoring function. Stateless; one instance for the
/// whole app.

@ProviderFor(matchScorer)
final matchScorerProvider = MatchScorerProvider._();

/// The pure-Dart scoring function. Stateless; one instance for the
/// whole app.

final class MatchScorerProvider
    extends $FunctionalProvider<MatchScorer, MatchScorer, MatchScorer>
    with $Provider<MatchScorer> {
  /// The pure-Dart scoring function. Stateless; one instance for the
  /// whole app.
  MatchScorerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'matchScorerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$matchScorerHash();

  @$internal
  @override
  $ProviderElement<MatchScorer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MatchScorer create(Ref ref) {
    return matchScorer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MatchScorer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MatchScorer>(value),
    );
  }
}

String _$matchScorerHash() => r'36af7be1bff4cc841c6a299ebc338137fd860078';

/// The signed-in user's [MatchPreferences], streamed from
/// `users/{uid}/private/matchPrefs`. Falls back to a default derived
/// from the user's profile when the document is missing.

@ProviderFor(currentMatchPreferences)
final currentMatchPreferencesProvider = CurrentMatchPreferencesProvider._();

/// The signed-in user's [MatchPreferences], streamed from
/// `users/{uid}/private/matchPrefs`. Falls back to a default derived
/// from the user's profile when the document is missing.

final class CurrentMatchPreferencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<MatchPreferences>,
          MatchPreferences,
          Stream<MatchPreferences>
        >
    with $FutureModifier<MatchPreferences>, $StreamProvider<MatchPreferences> {
  /// The signed-in user's [MatchPreferences], streamed from
  /// `users/{uid}/private/matchPrefs`. Falls back to a default derived
  /// from the user's profile when the document is missing.
  CurrentMatchPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentMatchPreferencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentMatchPreferencesHash();

  @$internal
  @override
  $StreamProviderElement<MatchPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<MatchPreferences> create(Ref ref) {
    return currentMatchPreferences(ref);
  }
}

String _$currentMatchPreferencesHash() =>
    r'84406550dff8252d92c8f557bcbf118b5ff54378';

/// Aggregated [ViewerContext] for the scorer. Built once per
/// viewer change so controllers don't refetch on profile change
/// without an explicit re-rank call.

@ProviderFor(viewerContext)
final viewerContextProvider = ViewerContextProvider._();

/// Aggregated [ViewerContext] for the scorer. Built once per
/// viewer change so controllers don't refetch on profile change
/// without an explicit re-rank call.

final class ViewerContextProvider
    extends $FunctionalProvider<ViewerContext, ViewerContext, ViewerContext>
    with $Provider<ViewerContext> {
  /// Aggregated [ViewerContext] for the scorer. Built once per
  /// viewer change so controllers don't refetch on profile change
  /// without an explicit re-rank call.
  ViewerContextProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'viewerContextProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$viewerContextHash();

  @$internal
  @override
  $ProviderElement<ViewerContext> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ViewerContext create(Ref ref) {
    return viewerContext(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ViewerContext value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ViewerContext>(value),
    );
  }
}

String _$viewerContextHash() => r'df213c8e9a47912e1ab5f8e26417ba6cff9e339c';
