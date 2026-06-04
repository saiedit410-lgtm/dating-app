import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/connections/application/connection_providers.dart';
import 'package:dating_app/features/connections/domain/friend_request.dart';
import 'package:dating_app/features/connections/presentation/widgets/user_list_tile.dart';
import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Incoming friend requests with Accept / Reject actions.
class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({super.key});

  Future<void> _respond(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Could not update the request.')),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? me = ref.watch(authStateChangesProvider).value?.uid;
    final AsyncValue<List<FriendRequest>> async = ref.watch(
      incomingRequestsProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Requests')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace _) =>
            const Center(child: Text('Could not load requests.')),
        data: (List<FriendRequest> requests) {
          if (requests.isEmpty || me == null) {
            return _empty(context);
          }
          return ListView.separated(
            itemCount: requests.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int index) {
              final FriendRequest request = requests[index];
              return UserListTile(
                uid: request.fromUid,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton.filledTonal(
                      tooltip: 'Accept',
                      icon: const Icon(Icons.check),
                      onPressed: () => _respond(
                        context,
                        () => ref
                            .read(connectionRepositoryProvider)
                            .acceptRequest(
                              fromUid: request.fromUid,
                              toUid: me,
                            ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: 'Reject',
                      icon: const Icon(Icons.close),
                      onPressed: () => _respond(
                        context,
                        () => ref
                            .read(connectionRepositoryProvider)
                            .rejectRequest(
                              fromUid: request.fromUid,
                              toUid: me,
                            ),
                      ),
                    ),
                  ],
                ),
              );
            },
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
            Icons.inbox_outlined,
            size: 64,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('No requests yet', style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'When someone wants to connect, it shows up here.',
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
