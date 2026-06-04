import 'package:dating_app/core/firebase/firebase_providers.dart';
import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/profile/data/firestore_profile_repository.dart';
import 'package:dating_app/features/profile/domain/profile_repository.dart';
import 'package:dating_app/features/profile/domain/user_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_providers.g.dart';

/// The app's [ProfileRepository] (Firestore-backed).
@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) =>
    FirestoreProfileRepository(ref.watch(firebaseFirestoreProvider));

/// Live profile of the signed-in user, or null. Emits null when signed out.
@Riverpod(keepAlive: true)
Stream<UserProfile?> currentUserProfile(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream<UserProfile?>.value(null);
  return ref.watch(profileRepositoryProvider).watchProfile(user.uid);
}
