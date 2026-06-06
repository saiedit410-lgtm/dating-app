import 'package:dating_app/core/routing/app_routes.dart';
import 'package:dating_app/features/discovery/application/discovery_controller.dart';
import 'package:dating_app/features/discovery/application/discovery_filters_controller.dart';
import 'package:dating_app/features/discovery/domain/discovery_filters.dart';
import 'package:dating_app/features/discovery/presentation/widgets/discovery_filter_sheet.dart';
import 'package:dating_app/features/matching/domain/feed_status.dart';
import 'package:dating_app/features/matching/domain/match_weights.dart';
import 'package:dating_app/features/matching/domain/ranked_feed_state.dart';
import 'package:dating_app/features/matching/domain/scored_profile.dart';
import 'package:dating_app/features/matching/presentation/screens/discovery_preferences_sheet.dart';
import 'package:dating_app/features/matching/presentation/widgets/score_breakdown_sheet.dart';
import 'package:dating_app/features/matching/presentation/widgets/scored_profile_card.dart';
import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The "All Discovery" tab body — paginated, filterable, **scored**
/// list of public profiles. Phase 2.2: single feed controller,
/// `RankedFeedState<ScoredProfile>`, shared `FeedStatus`.
class AllDiscoveryBody extends ConsumerStatefulWidget {
  const AllDiscoveryBody({super.key});

  @override
  ConsumerState<AllDiscoveryBody> createState() => _AllDiscoveryBodyState();
}

class _AllDiscoveryBodyState extends ConsumerState<AllDiscoveryBody> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(discoveryControllerProvider.notifier).loadInitial();
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
    if (_scroll.position.pixels >=
        _scroll.position.maxScrollExtent - 400) {
      ref.read(discoveryControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _openFilters() async {
    final DiscoveryFilters current =
        ref.read(discoveryFiltersControllerProvider);
    final DiscoveryFilters? result =
        await showModalBottomSheet<DiscoveryFilters>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => DiscoveryFilterSheet(initial: current),
    );
    if (result == null) return;
    await ref.read(discoveryFiltersControllerProvider.notifier).update(result);
    await ref.read(discoveryControllerProvider.notifier).refresh();
  }

  Future<void> _openPreferences() async {
    await DiscoveryPreferencesSheet.show(context);
    await ref.read(discoveryControllerProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final RankedFeedState<ScoredProfile> state =
        ref.watch(discoveryControllerProvider);
    final bool filtersActive =
        !ref.watch(discoveryFiltersControllerProvider).isDefault;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          child: Row(
            children: <Widget>[
              TextButton.icon(
                onPressed: _openPreferences,
                icon: const Icon(Icons.tune),
                label: const Text('Preferences'),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _openFilters,
                icon: Icon(
                  filtersActive
                      ? Icons.filter_alt
                      : Icons.filter_alt_outlined,
                ),
                label: Text(filtersActive ? 'Filters · on' : 'Filters'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(discoveryControllerProvider.notifier).refresh(),
            child: _body(state),
          ),
        ),
      ],
    );
  }

  Widget _body(RankedFeedState<ScoredProfile> state) {
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
            ref.read(discoveryControllerProvider.notifier).refresh(),
      );
    }
    if (state.items.isEmpty) {
      return _Message(
        icon: Icons.search_off,
        title: 'No one here yet',
        subtitle: 'Try widening your preferences or check back soon.',
        actionLabel: 'Adjust preferences',
        onAction: _openPreferences,
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
                  weights: MatchWeights.forAll,
                ),
        );
      },
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
