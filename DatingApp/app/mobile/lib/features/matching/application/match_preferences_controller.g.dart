// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_preferences_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns the [MatchPreferences] edit surface. Reads from
/// [currentMatchPreferencesProvider] on build, mutates via
/// [replace] for dirty-tracking, and [save] to persist. The
/// presentation sheet is built on top of this.

@ProviderFor(MatchPreferencesController)
final matchPreferencesControllerProvider =
    MatchPreferencesControllerProvider._();

/// Owns the [MatchPreferences] edit surface. Reads from
/// [currentMatchPreferencesProvider] on build, mutates via
/// [replace] for dirty-tracking, and [save] to persist. The
/// presentation sheet is built on top of this.
final class MatchPreferencesControllerProvider
    extends $NotifierProvider<MatchPreferencesController, MatchPreferences> {
  /// Owns the [MatchPreferences] edit surface. Reads from
  /// [currentMatchPreferencesProvider] on build, mutates via
  /// [replace] for dirty-tracking, and [save] to persist. The
  /// presentation sheet is built on top of this.
  MatchPreferencesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'matchPreferencesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$matchPreferencesControllerHash();

  @$internal
  @override
  MatchPreferencesController create() => MatchPreferencesController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MatchPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MatchPreferences>(value),
    );
  }
}

String _$matchPreferencesControllerHash() =>
    r'241501d08422cfba48a2cd040742ff43d602ff89';

/// Owns the [MatchPreferences] edit surface. Reads from
/// [currentMatchPreferencesProvider] on build, mutates via
/// [replace] for dirty-tracking, and [save] to persist. The
/// presentation sheet is built on top of this.

abstract class _$MatchPreferencesController
    extends $Notifier<MatchPreferences> {
  MatchPreferences build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MatchPreferences, MatchPreferences>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MatchPreferences, MatchPreferences>,
              MatchPreferences,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
