import 'package:dating_app/core/routing/app_routes.dart';
import 'package:dating_app/features/connections/presentation/widgets/user_list_tile.dart';
import 'package:dating_app/features/likes/application/likes_providers.dart';
import 'package:dating_app/features/safety/application/safety_providers.dart';
import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Recent visitors to the signed-in user's profile (newest first).
///
/// Visitors who are blocked by the profile owner are filtered out
/// at render time so the owner never sees a blocker in the list.
class RecentVisitorsScreen extends ConsumerWidget {
  const RecentVisitorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<dynamic>> async = ref.watch(recentVisitorsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recent visitors')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace _) =>
            const Center(child: Text('Could not load visitors.')),
        data: (List<dynamic> visitors) {
          if (visitors.isEmpty) return _empty(context);
          final Set<String> blocked =
              ref.watch(blockedUidsProvider).value ?? const <String>{};
          final List<dynamic> visible = visitors
              .where((dynamic v) => !blocked.contains(v.viewerUid as String))
              .toList();
          if (visible.isEmpty) return _empty(context);
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(recentVisitorsProvider),
            child: ListView.separated(
              itemCount: visible.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (BuildContext context, int index) {
                final String viewerUid = visible[index].viewerUid as String;
                return UserListTile(
                  uid: viewerUid,
                  onTap: () => context.pushNamed(
                    AppRoute.profileDetail.routeName,
                    pathParameters: <String, String>{'uid': viewerUid},
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _empty(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.visibility_outlined,
            size: 64,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('No visitors yet', style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            "When someone opens your profile, you'll see them here.",
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}
