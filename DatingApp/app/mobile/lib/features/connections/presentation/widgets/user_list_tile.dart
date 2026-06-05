import 'package:cached_network_image/cached_network_image.dart';
import 'package:dating_app/features/discovery/application/discovery_providers.dart';
import 'package:dating_app/features/discovery/domain/public_profile.dart';
import 'package:dating_app/shared/widgets/verified_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A reusable list row that resolves a [PublicProfile] by uid (so connection /
/// request docs store only references, never duplicated profile data).
class UserListTile extends ConsumerWidget {
  const UserListTile({super.key, required this.uid, this.trailing, this.onTap});

  final String uid;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PublicProfile?> async = ref.watch(
      profileByIdProvider(uid),
    );
    return async.when(
      loading: () => const ListTile(
        leading: CircleAvatar(child: Icon(Icons.person_outline)),
        title: Text('Loading…'),
      ),
      error: (Object e, StackTrace _) => const ListTile(
        leading: CircleAvatar(child: Icon(Icons.person_off_outlined)),
        title: Text('Unavailable'),
      ),
      data: (PublicProfile? profile) => _tile(profile),
    );
  }

  Widget _tile(PublicProfile? profile) {
    final String name = profile?.displayName ?? 'Someone';
    final String title = profile?.age == null ? name : '$name, ${profile!.age}';
    final String? url = profile?.primaryPhotoUrl;
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            url != null ? CachedNetworkImageProvider(url) : null,
        child: url == null ? const Icon(Icons.person_outline) : null,
      ),
      title: Row(
        children: <Widget>[
          Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
          if (profile?.isVerified ?? false) ...<Widget>[
            const SizedBox(width: 4),
            const VerifiedBadge(size: 16),
          ],
        ],
      ),
      subtitle: (profile?.locationLabel.isNotEmpty ?? false)
          ? Text(profile!.locationLabel)
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
