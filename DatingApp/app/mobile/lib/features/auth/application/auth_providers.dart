import 'package:dating_app/core/firebase/firebase_providers.dart';
import 'package:dating_app/features/auth/data/firebase_auth_repository.dart';
import 'package:dating_app/features/auth/data/user_repository.dart';
import 'package:dating_app/features/auth/domain/auth_repository.dart';
import 'package:dating_app/features/auth/domain/auth_user.dart';
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
