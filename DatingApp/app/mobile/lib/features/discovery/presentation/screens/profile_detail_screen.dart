import 'package:cached_network_image/cached_network_image.dart';
import 'package:dating_app/core/theme/app_colors.dart';
import 'package:dating_app/features/connections/presentation/widgets/connection_button.dart';
import 'package:dating_app/features/discovery/application/discovery_providers.dart';
import 'package:dating_app/features/discovery/domain/public_profile.dart';
import 'package:dating_app/features/profile/domain/profile_enums.dart';
import 'package:dating_app/features/profile/domain/profile_photo.dart';
import 'package:dating_app/features/safety/presentation/widgets/profile_safety_menu.dart';
import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full public profile: all photos, bio, location, and preferences.
class ProfileDetailScreen extends ConsumerWidget {
  const ProfileDetailScreen({
    super.key,
    required this.uid,
    this.initialProfile,
  });

  final String uid;
  final PublicProfile? initialProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (initialProfile != null) {
      return _DetailScaffold(profile: initialProfile!);
    }
    final AsyncValue<PublicProfile?> async = ref.watch(
      profileByIdProvider(uid),
    );
    return async.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (Object e, StackTrace _) => Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Could not load this profile.')),
      ),
      data: (PublicProfile? profile) => profile == null
          ? Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Profile not found.')),
            )
          : _DetailScaffold(profile: profile),
    );
  }
}

class _DetailScaffold extends StatelessWidget {
  const _DetailScaffold({required this.profile});

  final PublicProfile profile;

  @override
  Widget build(BuildContext context) {
    final String name = profile.displayName ?? 'Someone';
    final String title = profile.age == null ? name : '$name, ${profile.age}';

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: <Widget>[ProfileSafetyMenu(otherUid: profile.uid)],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConnectionButton(otherUid: profile.uid),
        ),
      ),
      body: ListView(
        children: <Widget>[
          _PhotoCarousel(photos: profile.photos),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(title, style: context.textTheme.headlineSmall),
                    ),
                    if (profile.isVerified) ...<Widget>[
                      const SizedBox(width: 8),
                      const Icon(Icons.verified, color: AppColors.trustBlue),
                    ],
                  ],
                ),
                if (profile.locationLabel.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  _IconLine(
                    icon: Icons.place_outlined,
                    text: <String?>[
                      profile.city,
                      profile.state,
                      profile.country,
                    ].where((String? s) => s != null && s.trim().isNotEmpty).join(', '),
                  ),
                ],
                if (profile.datingIntent != null) ...<Widget>[
                  const SizedBox(height: 8),
                  _IconLine(
                    icon: Icons.favorite_outline,
                    text: profile.datingIntent!.label,
                  ),
                ],
                if ((profile.bio?.trim().isNotEmpty ?? false)) ...<Widget>[
                  const SizedBox(height: 20),
                  Text('About', style: context.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(profile.bio!.trim(), style: context.textTheme.bodyLarge),
                ],
                if (profile.interestedIn.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 20),
                  Text('Interested in', style: context.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: profile.interestedIn
                        .map(
                          (Gender g) => Chip(label: Text(g.label)),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoCarousel extends StatelessWidget {
  const _PhotoCarousel({required this.photos});

  final List<ProfilePhoto> photos;

  @override
  Widget build(BuildContext context) {
    final Color bg = context.colorScheme.surfaceContainerHighest;
    if (photos.isEmpty) {
      return AspectRatio(
        aspectRatio: 1,
        child: ColoredBox(
          color: bg,
          child: const Icon(Icons.person_outline, size: 96),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: 1,
      child: PageView.builder(
        itemCount: photos.length,
        itemBuilder: (BuildContext context, int index) => CachedNetworkImage(
          imageUrl: photos[index].url,
          fit: BoxFit.cover,
          placeholder: (BuildContext context, String _) => ColoredBox(color: bg),
          errorWidget: (BuildContext context, String _, Object _) =>
              ColoredBox(
                color: bg,
                child: const Icon(Icons.broken_image_outlined, size: 48),
              ),
        ),
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
