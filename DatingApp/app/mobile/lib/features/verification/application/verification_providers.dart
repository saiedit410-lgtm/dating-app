import 'package:dating_app/core/firebase/firebase_providers.dart';
import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/verification/data/firestore_verification_repository.dart';
import 'package:dating_app/features/verification/domain/verification_repository.dart';
import 'package:dating_app/features/verification/domain/verification_request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'verification_providers.g.dart';

/// The app's [VerificationRepository] (Firestore + Storage).
@Riverpod(keepAlive: true)
VerificationRepository verificationRepository(Ref ref) =>
    FirestoreVerificationRepository(
      ref.watch(firebaseFirestoreProvider),
      ref.watch(firebaseStorageProvider),
    );

/// Live verification request for the signed-in user.
@riverpod
Stream<VerificationRequest?> myVerificationRequest(Ref ref) {
  final String? uid = ref.watch(authStateChangesProvider).value?.uid;
  if (uid == null) {
    return Stream<VerificationRequest?>.value(null);
  }
  return ref.watch(verificationRepositoryProvider).watchRequest(uid);
}
