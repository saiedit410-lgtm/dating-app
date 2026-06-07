import 'package:dating_app/features/admin/application/admin_providers.dart';
import 'package:dating_app/features/admin/domain/report_resolution.dart';
import 'package:dating_app/features/admin/domain/user_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admin_queue_controller.g.dart';

class AdminQueueState {
  const AdminQueueState({this.isBusy = false, this.message, this.error});

  final bool isBusy;
  final String? message;
  final String? error;

  AdminQueueState copyWith({
    bool? isBusy,
    String? message,
    String? error,
    bool clearMessage = false,
    bool clearError = false,
  }) {
    return AdminQueueState(
      isBusy: isBusy ?? this.isBusy,
      message: clearMessage ? null : (message ?? this.message),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

@riverpod
class AdminQueueController extends _$AdminQueueController {
  @override
  AdminQueueState build() => const AdminQueueState();

  Future<void> approveVerification(String uid) async {
    await _run(
      action: () async {
        await ref.read(adminRepositoryProvider).approveVerification(uid: uid);
      },
      successMessage: 'Verification approved.',
      errorMessage: 'Could not approve verification.',
    );
  }

  Future<void> rejectVerification({
    required String uid,
    required String reason,
  }) async {
    await _run(
      action: () async {
        await ref
            .read(adminRepositoryProvider)
            .rejectVerification(uid: uid, reason: reason);
      },
      successMessage: 'Verification rejected.',
      errorMessage: 'Could not reject verification.',
    );
  }

  Future<void> resolveReport({
    required String reportId,
    required ReportResolution resolution,
    String? note,
  }) async {
    await _run(
      action: () async {
        await ref
            .read(adminRepositoryProvider)
            .resolveReport(
              reportId: reportId,
              resolution: resolution,
              note: note,
            );
      },
      successMessage: 'Report resolved.',
      errorMessage: 'Could not resolve report.',
    );
  }

  Future<void> setUserStatus({
    required String uid,
    required UserStatus status,
    String? note,
  }) async {
    await _run(
      action: () async {
        await ref
            .read(adminRepositoryProvider)
            .setUserStatus(uid: uid, status: status, note: note);
      },
      successMessage: 'User status updated.',
      errorMessage: 'Could not update user status.',
    );
  }

  Future<void> _run({
    required Future<void> Function() action,
    required String successMessage,
    required String errorMessage,
  }) async {
    state = state.copyWith(isBusy: true, clearMessage: true, clearError: true);
    try {
      await action();
      state = state.copyWith(isBusy: false, message: successMessage);
    } catch (_) {
      state = state.copyWith(isBusy: false, error: errorMessage);
    }
  }
}
