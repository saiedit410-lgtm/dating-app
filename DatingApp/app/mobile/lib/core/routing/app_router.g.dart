// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The application's [GoRouter] with auth-aware route guards.
///
/// Reacts to [authStateChangesProvider]:
///  * session still resolving  -> Splash
///  * signed out               -> Login (and the OTP step)
///  * signed in                -> Home

@ProviderFor(goRouter)
final goRouterProvider = GoRouterProvider._();

/// The application's [GoRouter] with auth-aware route guards.
///
/// Reacts to [authStateChangesProvider]:
///  * session still resolving  -> Splash
///  * signed out               -> Login (and the OTP step)
///  * signed in                -> Home

final class GoRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The application's [GoRouter] with auth-aware route guards.
  ///
  /// Reacts to [authStateChangesProvider]:
  ///  * session still resolving  -> Splash
  ///  * signed out               -> Login (and the OTP step)
  ///  * signed in                -> Home
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

String _$goRouterHash() => r'2abdff73831642d80ad186897ca663493a3812e4';
