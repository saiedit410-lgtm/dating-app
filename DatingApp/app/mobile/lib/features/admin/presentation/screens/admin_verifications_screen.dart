import 'package:dating_app/core/routing/app_routes.dart';
import 'package:dating_app/features/admin/application/admin_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdminVerificationsScreen extends ConsumerWidget {
  const AdminVerificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verifications = ref.watch(pendingVerificationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Queue')),
      body: verifications.when(
        data: (items) => items.isEmpty
            ? const Center(child: Text('No pending verifications.'))
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item.uid),
                    subtitle: Text(item.status.name),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.pushNamed(
                      AppRoute.adminVerificationDetail.routeName,
                      pathParameters: <String, String>{'uid': item.uid},
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
      ),
    );
  }
}
