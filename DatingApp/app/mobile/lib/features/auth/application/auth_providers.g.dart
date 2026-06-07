// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's [AuthRepository] (Firebase-backed).

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// The app's [AuthRepository] (Firebase-backed).

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// The app's [AuthRepository] (Firebase-backed).
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'7455af170efcd8715f9a47f339802e227f08e863';

/// Repository for the `users/{uid}` document.

@ProviderFor(userRepository)
final userRepositoryProvider = UserRepositoryProvider._();

/// Repository for the `users/{uid}` document.

final class UserRepositoryProvider
    extends $FunctionalProvider<UserRepository, UserRepository, UserRepository>
    with $Provider<UserRepository> {
  /// Repository for the `users/{uid}` document.
  UserRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserRepository create(Ref ref) {
    return userRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserRepository>(value),
    );
  }
}

String _$userRepositoryHash() => r'3f06f0f7cc98e86a7c79b3e7b670728ad6c96b74';

/// Reactive auth state, used by the router guard and the UI. Emits the signed
/// in [AuthUser] or null. `AsyncLoading` until the persisted session resolves.

@ProviderFor(authStateChanges)
final authStateChangesProvider = AuthStateChangesProvider._();

/// Reactive auth state, used by the router guard and the UI. Emits the signed
/// in [AuthUser] or null. `AsyncLoading` until the persisted session resolves.

final class AuthStateChangesProvider
    extends
        $FunctionalProvider<AsyncValue<AuthUser?>, AuthUser?, Stream<AuthUser?>>
    with $FutureModifier<AuthUser?>, $StreamProvider<AuthUser?> {
  /// Reactive auth state, used by the router guard and the UI. Emits the signed
  /// in [AuthUser] or null. `AsyncLoading` until the persisted session resolves.
  AuthStateChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateChangesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateChangesHash();

  @$internal
  @override
  $StreamProviderElement<AuthUser?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AuthUser?> create(Ref ref) {
    return authStateChanges(ref);
  }
}

String _$authStateChangesHash() => r'43931ae149743f29a83691cb56ac6211f54a34ae';

/// Live boolean: true when the signed-in user's ID token carries the
/// `admin: true` custom claim. Yields `false` while loading, signed-out,
/// or when the token is being refreshed.
///
/// Phase 2.4 - the only way for the mobile client to know it can
/// reach the admin surface. The Cloud Function callables also
/// re-check the same claim server-side, so a stolen token that
/// somehow lost the claim by the time the function runs will be
/// rejected with `permission-denied`.

@ProviderFor(isCurrentUserAdmin)
final isCurrentUserAdminProvider = IsCurrentUserAdminProvider._();

/// Live boolean: true when the signed-in user's ID token carries the
/// `admin: true` custom claim. Yields `false` while loading, signed-out,
/// or when the token is being refreshed.
///
/// Phase 2.4 - the only way for the mobile client to know it can
/// reach the admin surface. The Cloud Function callables also
/// re-check the same claim server-side, so a stolen token that
/// somehow lost the claim by the time the function runs will be
/// rejected with `permission-denied`.

final class IsCurrentUserAdminProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Live boolean: true when the signed-in user's ID token carries the
  /// `admin: true` custom claim. Yields `false` while loading, signed-out,
  /// or when the token is being refreshed.
  ///
  /// Phase 2.4 - the only way for the mobile client to know it can
  /// reach the admin surface. The Cloud Function callables also
  /// re-check the same claim server-side, so a stolen token that
  /// somehow lost the claim by the time the function runs will be
  /// rejected with `permission-denied`.
  IsCurrentUserAdminProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isCurrentUserAdminProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isCurrentUserAdminHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return isCurrentUserAdmin(ref);
  }
}

String _$isCurrentUserAdminHash() =>
    r'd7b389c58230c91a727b3511de3e161bbb59bf4e';
