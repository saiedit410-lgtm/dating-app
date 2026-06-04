import 'package:cached_network_image/cached_network_image.dart';
import 'package:dating_app/core/theme/app_colors.dart';
import 'package:dating_app/features/discovery/domain/public_profile.dart';
import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:flutter/material.dart';

/// A discovery feed card: primary photo, name, age, location, bio preview.
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.profile, required this.onTap});

  final PublicProfile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String name = profile.displayName ?? 'Someone';
    final String title = profile.age == null ? name : '$name, ${profile.age}';
    final String? preview = profile.bioPreview();

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 4 / 5,
              child: _Photo(url: profile.primaryPhotoUrl),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleLarge,
                        ),
                      ),
                      if (profile.isVerified) ...<Widget>[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified,
                          size: 20,
                          color: AppColors.trustBlue,
                        ),
                      ],
                    ],
                  ),
                  if (profile.locationLabel.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.place_outlined,
                          size: 16,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            profile.locationLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (preview != null) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final Color bg = context.colorScheme.surfaceContainerHighest;
    if (url == null) {
      return ColoredBox(
        color: bg,
        child: Icon(
          Icons.person_outline,
          size: 64,
          color: context.colorScheme.onSurfaceVariant,
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      placeholder: (BuildContext context, String _) =>
          ColoredBox(color: bg),
      errorWidget: (BuildContext context, String _, Object _) => ColoredBox(
        color: bg,
        child: const Icon(Icons.broken_image_outlined, size: 48),
      ),
    );
  }
}
