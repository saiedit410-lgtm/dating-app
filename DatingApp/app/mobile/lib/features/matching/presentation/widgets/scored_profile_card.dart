import 'package:dating_app/core/theme/app_colors.dart';
import 'package:dating_app/features/discovery/domain/geo/distance.dart';
import 'package:dating_app/features/discovery/presentation/widgets/profile_card.dart';
import 'package:dating_app/features/matching/domain/scored_profile.dart';
import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:flutter/material.dart';

/// A discovery card for a [ScoredProfile].
///
/// Reuses [ProfileCard] for the photo / name / bio rendering, then
/// overlays a small distance pill (when known) and an optional match
/// badge in the top-right. Long-press opens the breakdown sheet via
/// [onShowBreakdown].
class ScoredProfileCard extends StatelessWidget {
  const ScoredProfileCard({
    super.key,
    required this.scored,
    required this.onTap,
    this.onShowBreakdown,
    this.showMatchBadge = true,
  });

  final ScoredProfile scored;
  final VoidCallback onTap;
  final VoidCallback? onShowBreakdown;
  final bool showMatchBadge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onLongPress: onShowBreakdown,
          child: ProfileCard(
            profile: scored.profile,
            onTap: onTap,
          ),
        ),
        if (scored.distanceKm != null)
          Positioned(
            top: 12,
            right: 12,
            child: _DistancePill(distanceKm: scored.distanceKm!),
          ),
        if (showMatchBadge)
          Positioned(
            top: 12,
            left: 12,
            child: _MatchBadge(percent: scored.scorePercent),
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

class _MatchBadge extends StatelessWidget {
  const _MatchBadge({required this.percent});
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.brandRose.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.favorite, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            '$percent% match',
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
