import 'package:dating_app/features/admin/application/admin_queue_controller.dart';
import 'package:dating_app/features/admin/domain/user_status.dart';
import 'package:dating_app/features/admin/presentation/widgets/user_status_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminUserDetailScreen extends ConsumerWidget {
  const AdminUserDetailScreen({required this.uid, super.key});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueState = ref.watch(adminQueueControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('User Detail')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('UID: $uid'),
            const SizedBox(height: 24),
            UserStatusButtons(
              isBusy: queueState.isBusy,
              onSelected: (status) => _showNoteDialog(context, ref, status),
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
      ),
    );
  }

  Future<void> _showNoteDialog(
    BuildContext context,
    WidgetRef ref,
    UserStatus status,
  ) async {
    final TextEditingController controller = TextEditingController();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set status to ${status.label}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Note (optional)'),
          maxLines: 3,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref
          .read(adminQueueControllerProvider.notifier)
          .setUserStatus(uid: uid, status: status, note: controller.text);
    }
    controller.dispose();
  }
}
