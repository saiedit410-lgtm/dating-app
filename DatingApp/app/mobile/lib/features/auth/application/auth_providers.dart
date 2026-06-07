import 'package:dating_app/core/firebase/firebase_providers.dart';
import 'package:dating_app/features/auth/data/firebase_auth_repository.dart';
import 'package:dating_app/features/auth/data/user_repository.dart';
import 'package:dating_app/features/auth/domain/auth_repository.dart';
import 'package:dating_app/features/auth/domain/auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

/// The app's [AuthRepository] (Firebase-backed).
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    FirebaseAuthRepository(ref.watch(firebaseAuthProvider));

/// Repository for the `users/{uid}` document.
@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) =>
    UserRepository(ref.watch(firebaseFirestoreProvider));

/// Reactive auth state, used by the router guard and the UI. Emits the signed
/// in [AuthUser] or null. `AsyncLoading` until the persisted session resolves.
@Riverpod(keepAlive: true)
Stream<AuthUser?> authStateChanges(Ref ref) =>
    ref.watch(authRepositoryProvider).authStateChanges();

/// Live boolean: true when the signed-in user's ID token carries the
/// `admin: true` custom claim. Yields `false` while loading, signed-out,
/// or when the token is being refreshed.
///
/// Phase 2.4 - the only way for the mobile client to know it can
/// reach the admin surface. The Cloud Function callables also
/// re-check the same claim server-side, so a stolen token that
/// somehow lost the claim by the time the function runs will be
/// rejected with `permission-denied`.
@Riverpod(keepAlive: true)
Stream<bool> isCurrentUserAdmin(Ref ref) async* {
  final AuthUser? me = ref.watch(authStateChangesProvider).value;
  if (me == null) {
    yield false;
    return;
  }
  final User? fbUser = FirebaseAuth.instance.currentUser;
  if (fbUser == null || fbUser.uid != me.uid) {
    yield false;
    return;
  }
  final idTokenResult = await fbUser.getIdTokenResult(/* forceRefresh */ true);
  yield idTokenResult.claims?['admin'] == true;
}
