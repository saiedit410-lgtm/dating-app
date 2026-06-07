import 'package:dating_app/core/routing/app_routes.dart';
import 'package:dating_app/features/admin/application/admin_providers.dart';
import 'package:dating_app/features/admin/application/admin_queue_controller.dart';
import 'package:dating_app/features/admin/domain/report_resolution.dart';
import 'package:dating_app/features/admin/presentation/widgets/report_resolution_buttons.dart';
import 'package:dating_app/features/safety/domain/report.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdminReportDetailScreen extends ConsumerWidget {
  const AdminReportDetailScreen({required this.reportId, super.key});

  final String reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueState = ref.watch(adminQueueControllerProvider);
    final reports = ref.watch(openReportsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Report Detail')),
      body: reports.when(
        data: (items) {
          final Report? item = _findReport(items, reportId);
          if (item == null) {
            return const Center(child: Text('Report not found.'));
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Category: ${item.category.label}'),
                const SizedBox(height: 8),
                Text('Description: ${item.description}'),
                const SizedBox(height: 8),
                Text('Reported user: ${item.reportedUid}'),
                const SizedBox(height: 8),
                Text('Reporter: ${item.reporterUid}'),
                const SizedBox(height: 24),
                ReportResolutionButtons(
                  isBusy: queueState.isBusy,
                  onSelected: (resolution) =>
                      _resolve(context, ref, resolution),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.pushNamed(
                    AppRoute.adminUserDetail.routeName,
                    pathParameters: <String, String>{'uid': item.reportedUid},
                  ),
                  icon: const Icon(Icons.person_outline),
                  label: const Text('Open user detail'),
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

  Report? _findReport(List<Report> items, String id) {
    for (final Report item in items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  Future<void> _resolve(
    BuildContext context,
    WidgetRef ref,
    ReportResolution resolution,
  ) async {
    final TextEditingController controller = TextEditingController();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resolve as ${resolution.label}'),
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
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref
          .read(adminQueueControllerProvider.notifier)
          .resolveReport(
            reportId: reportId,
            resolution: resolution,
            note: controller.text,
          );
    }
    controller.dispose();
  }
}
