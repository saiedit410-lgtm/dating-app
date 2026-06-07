import 'package:dating_app/core/firebase/firebase_providers.dart';
import 'package:dating_app/features/admin/data/firestore_admin_repository.dart';
import 'package:dating_app/features/admin/domain/admin_action.dart';
import 'package:dating_app/features/admin/domain/admin_repository.dart';
import 'package:dating_app/features/safety/domain/report.dart';
import 'package:dating_app/features/verification/domain/verification_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<AdminRepository> adminRepositoryProvider =
    Provider<AdminRepository>(
      (Ref ref) => FirestoreAdminRepository(
        ref.watch(firebaseFirestoreProvider),
        ref.watch(firebaseFunctionsProvider),
      ),
    );

final StreamProvider<List<VerificationRequest>> pendingVerificationsProvider =
    StreamProvider<List<VerificationRequest>>(
      (Ref ref) =>
          ref.watch(adminRepositoryProvider).watchPendingVerifications(),
    );

final StreamProvider<List<Report>> openReportsProvider =
    StreamProvider<List<Report>>(
      (Ref ref) => ref.watch(adminRepositoryProvider).watchOpenReports(),
    );

final StreamProvider<List<AdminAction>> adminAuditLogProvider =
    StreamProvider<List<AdminAction>>(
      (Ref ref) => ref.watch(adminRepositoryProvider).watchAuditLog(),
    );
