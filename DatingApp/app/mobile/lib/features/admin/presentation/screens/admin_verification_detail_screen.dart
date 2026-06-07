import 'package:dating_app/features/admin/application/admin_providers.dart';
import 'package:dating_app/features/admin/application/admin_queue_controller.dart';
import 'package:dating_app/features/admin/presentation/widgets/admin_action_buttons.dart';
import 'package:dating_app/features/verification/domain/verification_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminVerificationDetailScreen extends ConsumerWidget {
  const AdminVerificationDetailScreen({required this.uid, super.key});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueState = ref.watch(adminQueueControllerProvider);
    final verifications = ref.watch(pendingVerificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Verification Detail')),
      body: verifications.when(
        data: (items) {
          final VerificationRequest? item = _findVerification(items, uid);
          if (item == null) {
            return const Center(child: Text('Verification request not found.'));
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('UID: ${item.uid}'),
                const SizedBox(height: 8),
                Text('Status: ${item.status.name}'),
                const SizedBox(height: 24),
                AdminActionButtons(
                  primaryLabel: 'Approve',
                  onPrimary: () => ref
                      .read(adminQueueControllerProvider.notifier)
                      .approveVerification(uid),
                  secondaryLabel: 'Reject',
                  onSecondary: () => _showRejectDialog(context, ref),
                  isBusy: queueState.isBusy,
                ),
                if (queueState.message != null) ...<Widget>[
                  const SizedBox(height: 16),
                  Text(queueState.message!),
                ],
                if (queueState.error != null) ...<Widget>[
                  const SizedBox(height: 16),
                  Text(queueState.error!),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
      ),
    );
  }

  VerificationRequest? _findVerification(
    List<VerificationRequest> items,
    String id,
  ) {
    for (final VerificationRequest item in items) {
      if (item.uid == id) {
        return item;
      }
    }
    return null;
  }

  Future<void> _showRejectDialog(BuildContext context, WidgetRef ref) async {
    final TextEditingController controller = TextEditingController();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject verification'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Reason'),
          maxLines: 3,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref
          .read(adminQueueControllerProvider.notifier)
          .rejectVerification(uid: uid, reason: controller.text);
    }
    controller.dispose();
  }
}
