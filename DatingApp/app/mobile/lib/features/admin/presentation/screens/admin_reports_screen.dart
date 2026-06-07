import 'package:dating_app/core/routing/app_routes.dart';
import 'package:dating_app/features/admin/application/admin_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(openReportsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Reports Queue')),
      body: reports.when(
        data: (items) => items.isEmpty
            ? const Center(child: Text('No open reports.'))
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item.category.label),
                    subtitle: Text(item.reportedUid),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.pushNamed(
                      AppRoute.adminReportDetail.routeName,
                      pathParameters: <String, String>{'reportId': item.id},
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
