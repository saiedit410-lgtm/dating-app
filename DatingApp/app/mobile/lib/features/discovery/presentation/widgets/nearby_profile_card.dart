import 'package:dating_app/core/theme/app_colors.dart';
import 'package:dating_app/features/discovery/domain/geo/distance.dart';
import 'package:dating_app/features/discovery/domain/nearby_profile.dart';
import 'package:dating_app/features/discovery/presentation/widgets/profile_card.dart';
import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:flutter/material.dart';

/// A discovery card with a distance pill overlaid on the photo.
///
/// Reuses [ProfileCard] for the photo / name / bio rendering so visuals
/// stay consistent with the All Discovery tab.
class NearbyProfileCard extends StatelessWidget {
  const NearbyProfileCard({
    super.key,
    required this.nearby,
    required this.onTap,
  });

  final NearbyProfile nearby;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ProfileCard(profile: nearby.profile, onTap: onTap),
        Positioned(
          top: 12,
          right: 12,
          child: _DistancePill(distanceKm: nearby.distanceKm),
        ),
      ],
    );
  }
}

class _DistancePill extends StatelessWidget {
  const _DistancePill({required this.distanceKm});

  final double distanceKm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.trustBlue.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.near_me_outlined, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            formatDistanceKm(distanceKm),
            style: context.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
