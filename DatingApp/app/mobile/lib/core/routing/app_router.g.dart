// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The application's [GoRouter] with auth + onboarding aware route guards.
///
/// Reacts to [appStartupStageProvider] (a coarse enum), so the router only
/// rebuilds when the routing decision changes - not on every profile edit:
///  * loading   -> Splash
///  * loggedOut -> Login / OTP
///  * onboarding-> Onboarding
///  * ready      -> Home

@ProviderFor(goRouter)
final goRouterProvider = GoRouterProvider._();

/// The application's [GoRouter] with auth + onboarding aware route guards.
///
/// Reacts to [appStartupStageProvider] (a coarse enum), so the router only
/// rebuilds when the routing decision changes - not on every profile edit:
///  * loading   -> Splash
///  * loggedOut -> Login / OTP
///  * onboarding-> Onboarding
///  * ready      -> Home

final class GoRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The application's [GoRouter] with auth + onboarding aware route guards.
  ///
  /// Reacts to [appStartupStageProvider] (a coarse enum), so the router only
  /// rebuilds when the routing decision changes - not on every profile edit:
  ///  * loading   -> Splash
  ///  * loggedOut -> Login / OTP
  ///  * onboarding-> Onboarding
  ///  * ready      -> Home
  GoRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return goRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$goRouterHash() => r'49b804ea196ba1a2d1532abedc56f4224f518e74';
