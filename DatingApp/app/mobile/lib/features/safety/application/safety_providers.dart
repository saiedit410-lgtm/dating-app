import 'package:dating_app/core/firebase/firebase_providers.dart';
import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/safety/data/firestore_safety_repository.dart';
import 'package:dating_app/features/safety/domain/safety_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'safety_providers.g.dart';

/// The app's [SafetyRepository] (Firestore-backed).
@Riverpod(keepAlive: true)
SafetyRepository safetyRepository(Ref ref) =>
    FirestoreSafetyRepository(ref.watch(firebaseFirestoreProvider));

/// Uids hidden from the current user (mutual blocks). Discovery, connections
/// and chat all honour this set. Empty when signed out.
@Riverpod(keepAlive: true)
Stream<Set<String>> blockedUids(Ref ref) {
  final String? me = ref.watch(authStateChangesProvider).value?.uid;
  if (me == null) return Stream<Set<String>>.value(const <String>{});
  return ref.watch(safetyRepositoryProvider).watchBlockedUids(me);
}
