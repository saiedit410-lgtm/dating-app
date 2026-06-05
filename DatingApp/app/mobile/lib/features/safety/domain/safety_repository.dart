import 'package:dating_app/features/safety/domain/report.dart';

/// Blocking + reporting. Implemented by Firestore.
abstract interface class SafetyRepository {
  /// All uids hidden from [me] in both directions: users [me] has blocked and
  /// users who have blocked [me] (mutual invisibility).
  Stream<Set<String>> watchBlockedUids(String me);

  Future<void> blockUser({
    required String blockerUid,
    required String blockedUid,
  });

  Future<void> unblockUser({
    required String blockerUid,
    required String blockedUid,
  });

  Future<void> submitReport({
    required String reporterUid,
    required String reportedUid,
    required ReportCategory category,
    required String description,
  });
}
