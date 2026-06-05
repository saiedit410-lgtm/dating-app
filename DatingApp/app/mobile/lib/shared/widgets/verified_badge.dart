import 'package:dating_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// The verified-profile trust badge (`trust/verified` blue check).
///
/// Render only when a user's `isVerified == true`. Shared across discovery
/// cards, profile detail, chat, and connection lists for visual consistency.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.size = 18, this.visible = true});

  final double size;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Icon(Icons.verified, size: size, color: AppColors.trustBlue);
  }
}
