import 'package:dating_app/core/routing/app_routes.dart';
import 'package:dating_app/features/discovery/application/discovery_controller.dart';
import 'package:dating_app/features/discovery/application/discovery_filters_controller.dart';
import 'package:dating_app/features/discovery/domain/discovery_filters.dart';
import 'package:dating_app/features/discovery/domain/public_profile.dart';
import 'package:dating_app/features/discovery/presentation/widgets/discovery_filter_sheet.dart';
import 'package:dating_app/features/discovery/presentation/widgets/profile_card.dart';
import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The "All Discovery" tab body — paginated, filterable list of public
/// profiles. Lifted out of [DiscoveryScreen] so the screen can host the
/// All / Nearby tab switcher.
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
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
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

  @override
  Widget build(BuildContext context) {
    final DiscoveryState state = ref.watch(discoveryControllerProvider);
    final bool filtersActive =
        !ref.watch(discoveryFiltersControllerProvider).isDefault;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          child: Row(
            children: <Widget>[
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

  Widget _body(DiscoveryState state) {
    if (state.isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == DiscoveryStatus.error && state.profiles.isEmpty) {
      return _Message(
        icon: Icons.error_outline,
        title: 'Something went wrong',
        subtitle: state.errorMessage ?? 'Please try again.',
        actionLabel: 'Retry',
        onAction: () =>
            ref.read(discoveryControllerProvider.notifier).refresh(),
      );
    }
    if (state.profiles.isEmpty) {
      return _Message(
        icon: Icons.search_off,
        title: 'No one here yet',
        subtitle: 'Try widening your filters or check back soon.',
        actionLabel: 'Adjust filters',
        onAction: _openFilters,
      );
    }

    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.profiles.length + (state.hasMore ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (index >= state.profiles.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final PublicProfile profile = state.profiles[index];
        return ProfileCard(
          profile: profile,
          onTap: () => context.pushNamed(
            AppRoute.profileDetail.routeName,
            pathParameters: <String, String>{'uid': profile.uid},
            extra: profile,
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
