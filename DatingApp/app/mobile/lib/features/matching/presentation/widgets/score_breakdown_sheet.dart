import 'package:dating_app/features/matching/domain/match_weights.dart';
import 'package:dating_app/features/matching/domain/scored_profile.dart';
import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:flutter/material.dart';

/// Bottom sheet explaining why a [ScoredProfile] is ranked where it is.
///
/// Shows the top contributing terms (per
/// [ScoredProfile.topReasons]) and the composite score. Designed to
/// be triggered by long-press on a card; not a primary surface.
class ScoreBreakdownSheet extends StatelessWidget {
  const ScoreBreakdownSheet({
    super.key,
    required this.scored,
    this.weights = MatchWeights.forAll,
  });

  final ScoredProfile scored;
  final MatchWeights weights;

  static Future<void> show(
    BuildContext context, {
    required ScoredProfile scored,
    MatchWeights weights = MatchWeights.forAll,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => ScoreBreakdownSheet(
        scored: scored,
        weights: weights,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> reasons = scored.topReasons();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.favorite,
                  color: context.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${scored.scorePercent}% match',
                  style: context.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Why we think you might click',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            if (reasons.isEmpty)
              Text(
                'Limited signal on this profile right now.',
                style: context.textTheme.bodyMedium,
              )
            else
              ...reasons.map(
                (String r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: context.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(r, style: context.textTheme.bodyMedium),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Score is a private signal — other users do not see your exact score.',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
