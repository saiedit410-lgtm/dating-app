import 'package:dating_app/core/routing/app_routes.dart';
import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/likes/application/likes_providers.dart';
import 'package:dating_app/features/likes/domain/like.dart';
import 'package:dating_app/features/safety/application/safety_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Like-button + mutual-likes badge shown on a profile detail screen.
///
/// Reflects the current `hasLikedOther` state:
///   * not liked  -> Outlined "Like" button
///   * liked      -> Filled "Liked" button (tap to unlike)
///   * mutual     -> Filled "It's a match!" with a chat shortcut
///
/// Records a profile view on first build (only once per session, via
/// a per-screen [Map] of viewer→profile pairs in this widget's
/// state — kept simple here as a `StatefulWidget`).
class LikeButton extends ConsumerStatefulWidget {
  const LikeButton({super.key, required this.otherUid});

  final String otherUid;

  @override
  ConsumerState<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends ConsumerState<LikeButton> {
  bool _busy = false;
  bool _viewRecorded = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Something went wrong. Try again.')),
          );
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  void _maybeRecordView() {
    if (_viewRecorded) return;
    _viewRecorded = true;
    final String? me = ref.read(authStateChangesProvider).value?.uid;
    if (me == null || me == widget.otherUid) return;
    // Fire-and-forget; the viewer's identity is the only stamp.
    // Failures are surfaced by the `recentVisitorsProvider` on the
    // profile owner's side via Firestore's permission error if rules
    // are misconfigured.
    ref
        .read(profileVisitorRepositoryProvider)
        .recordView(viewerUid: me, profileUid: widget.otherUid);
  }

  @override
  Widget build(BuildContext context) {
    final String? me = ref.watch(authStateChangesProvider).value?.uid;
    if (me == null || me == widget.otherUid) return const SizedBox.shrink();

    // Blocked users must not see the like surface.
    final Set<String> blocked =
        ref.watch(blockedUidsProvider).value ?? const <String>{};
    if (blocked.contains(widget.otherUid)) return const SizedBox.shrink();

    // Mutual-likes: I liked them AND they liked me.
    final AsyncValue<bool> hasLiked = ref.watch(
      hasLikedOtherProvider(widget.otherUid),
    );
    final AsyncValue<List<Like>> received = ref.watch(receivedLikesProvider);
    final bool mutual = hasLiked.value == true &&
        (received.value ?? const <Like>[])
            .any((Like l) => l.fromUid == widget.otherUid);

    _maybeRecordView();

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

    if (mutual) {
      return FilledButton.icon(
        onPressed: () => context.pushNamed(
          AppRoute.chat.routeName,
          pathParameters: <String, String>{'uid': widget.otherUid},
        ),
        icon: const Icon(Icons.favorite),
        label: const Text("It's a match — say hi"),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      );
    }

    final bool liked = hasLiked.value == true;
    if (liked) {
      return OutlinedButton.icon(
        onPressed: () => _run(
          () => ref
              .read(likeRepositoryProvider)
              .unlike(fromUid: me, toUid: widget.otherUid),
        ),
        icon: const Icon(Icons.favorite, color: Colors.pink),
        label: const Text('Liked · Tap to undo'),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      );
    }
    return FilledButton.icon(
      onPressed: () => _run(
        () => ref
            .read(likeRepositoryProvider)
            .like(fromUid: me, toUid: widget.otherUid),
      ),
      icon: const Icon(Icons.favorite_border),
      label: const Text('Like'),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
    );
  }
}
