import 'package:dating_app/features/admin/application/admin_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminAuditScreen extends ConsumerWidget {
  const AdminAuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audit = ref.watch(adminAuditLogProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Audit Log')),
      body: audit.when(
        data: (items) => items.isEmpty
            ? const Center(child: Text('No admin actions yet.'))
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item.action.wire),
                    subtitle: Text(
                      '${item.targetType.name}: ${item.targetUid}',
                    ),
                    trailing: Text(item.adminUid),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
      ),
    );
  }
}
