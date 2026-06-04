import 'package:dating_app/core/routing/app_routes.dart';
import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/connections/application/connection_providers.dart';
import 'package:dating_app/features/connections/domain/friend_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Relationship-aware action button shown on a profile detail screen.
///
/// Reflects the current [RelationshipState]:
///   notConnected    -> Send request
///   requestSent     -> Requested (tap to cancel)
///   requestReceived -> Accept / Reject
///   connected       -> Connected (no send button)
class ConnectionButton extends ConsumerStatefulWidget {
  const ConnectionButton({super.key, required this.otherUid});

  final String otherUid;

  @override
  ConsumerState<ConnectionButton> createState() => _ConnectionButtonState();
}

class _ConnectionButtonState extends ConsumerState<ConnectionButton> {
  bool _busy = false;

  Future<void> _run(Future<void> Function(String me) action) async {
    final String? me = ref.read(authStateChangesProvider).value?.uid;
    if (me == null) return;
    setState(() => _busy = true);
    try {
      await action(me);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Something went wrong. Try again.')),
          );
      }
    }
    ref.invalidate(relationshipProvider(widget.otherUid));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final String? me = ref.watch(authStateChangesProvider).value?.uid;
    if (me == null || me == widget.otherUid) return const SizedBox.shrink();

    final AsyncValue<RelationshipState> rel = ref.watch(
      relationshipProvider(widget.otherUid),
    );

    return rel.maybeWhen(
      data: (RelationshipState state) => _buttons(state),
      orElse: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      ),
    );
  }

  Widget _buttons(RelationshipState state) {
    final String other = widget.otherUid;
    if (_busy) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    switch (state) {
      case RelationshipState.notConnected:
        return FilledButton.icon(
          onPressed: () => _run(
            (String me) => ref
                .read(connectionRepositoryProvider)
                .sendRequest(fromUid: me, toUid: other),
          ),
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Send request'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        );
      case RelationshipState.requestSent:
        return OutlinedButton.icon(
          onPressed: () => _run(
            (String me) => ref
                .read(connectionRepositoryProvider)
                .cancelRequest(fromUid: me, toUid: other),
          ),
          icon: const Icon(Icons.hourglass_top),
          label: const Text('Requested · Tap to cancel'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        );
      case RelationshipState.requestReceived:
        return Row(
          children: <Widget>[
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _run(
                  (String me) => ref
                      .read(connectionRepositoryProvider)
                      .acceptRequest(fromUid: other, toUid: me),
                ),
                icon: const Icon(Icons.check),
                label: const Text('Accept'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _run(
                  (String me) => ref
                      .read(connectionRepositoryProvider)
                      .rejectRequest(fromUid: other, toUid: me),
                ),
                icon: const Icon(Icons.close),
                label: const Text('Reject'),
              ),
            ),
          ],
        );
      case RelationshipState.connected:
        return FilledButton.icon(
          onPressed: () => context.pushNamed(
            AppRoute.chat.routeName,
            pathParameters: <String, String>{'uid': other},
          ),
          icon: const Icon(Icons.forum_outlined),
          label: const Text('Message'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        );
    }
  }
}
