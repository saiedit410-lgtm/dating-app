import 'package:dating_app/core/routing/app_routes.dart';
import 'package:dating_app/features/discovery/application/location_controller.dart';
import 'package:dating_app/features/discovery/application/nearby_controller.dart';
import 'package:dating_app/features/discovery/domain/location_permission_state.dart';
import 'package:dating_app/features/discovery/domain/nearby_radius.dart';
import 'package:dating_app/features/matching/domain/feed_status.dart';
import 'package:dating_app/features/matching/domain/match_weights.dart';
import 'package:dating_app/features/matching/domain/ranked_feed_state.dart';
import 'package:dating_app/features/matching/domain/scored_profile.dart';
import 'package:dating_app/features/matching/presentation/widgets/score_breakdown_sheet.dart';
import 'package:dating_app/features/matching/presentation/widgets/scored_profile_card.dart';
import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' show Geolocator;
import 'package:go_router/go_router.dart';

/// The "Nearby" discovery feed. Owns the permission prompt UI and
/// renders the radius-scoped, scored list.
class NearbyScreen extends ConsumerStatefulWidget {
  const NearbyScreen({super.key});

  @override
  ConsumerState<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends ConsumerState<NearbyScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = ref.read(locationControllerProvider.notifier);
      loc.checkStatus().then((_) {
        if (ref.read(locationControllerProvider).status ==
            LocationStatus.ready) {
          ref.read(nearbyControllerProvider.notifier).loadInitial();
        }
      });
    });
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
      ref.read(nearbyControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(locationControllerProvider.notifier).refresh();
    if (ref.read(locationControllerProvider).status == LocationStatus.ready) {
      await ref.read(nearbyControllerProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final LocationState loc = ref.watch(locationControllerProvider);
    final RankedFeedState<ScoredProfile> nearby =
        ref.watch(nearbyControllerProvider);
    final NearbyRadius radius = ref.watch(nearbyRadiusControllerProvider);

    if (loc.status != LocationStatus.ready || loc.location == null) {
      return _LocationPrompt(state: loc);
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Column(
        children: <Widget>[
          _RadiusSelector(
            current: radius,
            onChanged: (NearbyRadius r) =>
                ref.read(nearbyControllerProvider.notifier).setRadius(r),
          ),
          const Divider(height: 1),
          Expanded(child: _body(nearby, radius)),
        ],
      ),
    );
  }

  Widget _body(RankedFeedState<ScoredProfile> state, NearbyRadius radius) {
    if (state.isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == FeedStatus.error && state.items.isEmpty) {
      return _Message(
        icon: Icons.error_outline,
        title: 'Something went wrong',
        subtitle: state.errorMessage ?? 'Please try again.',
        actionLabel: 'Retry',
        onAction: () =>
            ref.read(nearbyControllerProvider.notifier).refresh(),
      );
    }
    if (state.items.isEmpty) {
      return _Message(
        icon: Icons.travel_explore_outlined,
        title: 'No one nearby (yet)',
        subtitle:
            "We didn't find anyone within ${radius.label}. Try a larger radius or check back soon.",
        actionLabel: 'Refresh',
        onAction: () => ref.read(nearbyControllerProvider.notifier).refresh(),
      );
    }

    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.items.length + (state.hasMore ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (index >= state.items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final ScoredProfile scored = state.items[index];
        return ScoredProfileCard(
          scored: scored,
          onTap: () => context.pushNamed(
            AppRoute.profileDetail.routeName,
            pathParameters: <String, String>{'uid': scored.profile.uid},
            extra: scored.profile,
          ),
          onShowBreakdown: scored.terms.isEmpty
              ? null
              : () => ScoreBreakdownSheet.show(
                  context,
                  scored: scored,
                  weights: MatchWeights.forNearby,
                ),
        );
      },
    );
  }
}

/// Chips to switch between 5/10/25/50 km.
class _RadiusSelector extends StatelessWidget {
  const _RadiusSelector({required this.current, required this.onChanged});

  final NearbyRadius current;
  final ValueChanged<NearbyRadius> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            for (final NearbyRadius r in NearbyRadius.values) ...<Widget>[
              ChoiceChip(
                label: Text(r.label),
                selected: r == current,
                onSelected: (_) => onChanged(r),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

/// Rendered when we don't yet have a usable location.
class _LocationPrompt extends ConsumerWidget {
  const _LocationPrompt({required this.state});

  final LocationState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LocationPermissionState p = state.permission;
    final String title;
    final String subtitle;
    final String actionLabel;
    final IconData icon;
    final VoidCallback action;

    if (state.status == LocationStatus.checking) {
      return const Center(child: CircularProgressIndicator());
    }
    if (p == LocationPermissionState.permanentlyDenied) {
      icon = Icons.location_disabled;
      title = 'Location is blocked';
      subtitle =
          'Location permission is turned off for Spark. Enable it in system settings to see people nearby.';
      actionLabel = 'Open settings';
      action = Geolocator.openAppSettings;
    } else if (p == LocationPermissionState.serviceDisabled) {
      icon = Icons.location_off_outlined;
      title = 'Turn on location';
      subtitle =
          "Your device's location service is off. Turn it on to see people nearby.";
      actionLabel = 'Open settings';
      action = Geolocator.openLocationSettings;
    } else {
      icon = Icons.my_location;
      title = 'Find people nearby';
      subtitle =
          'We use your approximate location to show people within a few kilometers. We never share your exact location.';
      actionLabel = p == LocationPermissionState.granted
          ? 'Try again'
          : 'Allow location';
      action = () =>
          ref.read(locationControllerProvider.notifier).requestAndCapture();
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        SizedBox(height: MediaQuery.of(context).size.height * 0.12),
        Icon(icon, size: 64, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(height: 16),
        Text(title,
            textAlign: TextAlign.center,
            style: context.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        if (state.errorMessage != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(
            state.errorMessage!,
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Center(
          child: FilledButton.tonal(
            onPressed: action,
            child: Text(actionLabel),
          ),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        SizedBox(height: MediaQuery.of(context).size.height * 0.18),
        Icon(icon, size: 64, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(height: 16),
        Center(child: Text(title, style: context.textTheme.titleMedium)),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton.tonal(
            onPressed: onAction,
            child: Text(actionLabel),
          ),
        ),
      ],
    );
  }
}
