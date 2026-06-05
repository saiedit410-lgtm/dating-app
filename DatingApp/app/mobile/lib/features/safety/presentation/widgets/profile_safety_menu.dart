import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/safety/application/safety_providers.dart';
import 'package:dating_app/features/safety/domain/report.dart';
import 'package:dating_app/features/safety/presentation/widgets/report_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Overflow menu (Block / Report) for another user's profile.
class ProfileSafetyMenu extends ConsumerWidget {
  const ProfileSafetyMenu({super.key, required this.otherUid});

  final String otherUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? me = ref.watch(authStateChangesProvider).value?.uid;
    if (me == null || me == otherUid) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      tooltip: 'More',
      onSelected: (String value) async {
        if (value == 'report') {
          await _report(context, ref, me);
        } else if (value == 'block') {
          await _block(context, ref, me);
        }
      },
      itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
        PopupMenuItem<String>(value: 'report', child: Text('Report')),
        PopupMenuItem<String>(value: 'block', child: Text('Block')),
      ],
    );
  }

  Future<void> _report(BuildContext context, WidgetRef ref, String me) async {
    final (ReportCategory, String)? result =
        await showModalBottomSheet<(ReportCategory, String)>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => const ReportSheet(),
        );
    if (result == null) return;
    try {
      await ref
          .read(safetyRepositoryProvider)
          .submitReport(
            reporterUid: me,
            reportedUid: otherUid,
            category: result.$1,
            description: result.$2,
          );
      if (context.mounted) {
        _toast(context, 'Report submitted. Thanks for keeping Spark safe.');
      }
    } catch (_) {
      if (context.mounted) {
        _toast(context, 'Could not submit the report. Please try again.');
      }
    }
  }

  Future<void> _block(BuildContext context, WidgetRef ref, String me) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Block this user?'),
        content: const Text(
          "They won't be able to find, message, or send you requests, and "
          "they'll disappear from your discovery and connections.",
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Block'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(safetyRepositoryProvider)
          .blockUser(blockerUid: me, blockedUid: otherUid);
      if (context.mounted) {
        _toast(context, 'User blocked.');
        Navigator.of(context).maybePop();
      }
    } catch (_) {
      if (context.mounted) {
        _toast(context, 'Could not block this user. Please try again.');
      }
    }
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
