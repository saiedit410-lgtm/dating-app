import 'package:dating_app/core/routing/app_routes.dart';
import 'package:dating_app/features/connections/application/connections_controller.dart';
import 'package:dating_app/features/connections/domain/connection.dart';
import 'package:dating_app/features/connections/presentation/widgets/user_list_tile.dart';
import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Lists the signed-in user's accepted connections, paginated.
class ConnectionsScreen extends ConsumerStatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  ConsumerState<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends ConsumerState<ConnectionsScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(connectionsControllerProvider.notifier).loadInitial();
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
      ref.read(connectionsControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ConnectionsState state = ref.watch(connectionsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Connections')),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(connectionsControllerProvider.notifier).refresh(),
        child: _body(state),
      ),
    );
  }

  Widget _body(ConnectionsState state) {
    if (state.isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == ConnectionsStatus.error && state.connections.isEmpty) {
      return _message(
        icon: Icons.error_outline,
        text: 'Could not load connections.',
      );
    }
    if (state.connections.isEmpty) {
      return _message(
        icon: Icons.people_outline,
        text: 'No connections yet. Accept a request to get started.',
      );
    }
    return ListView.builder(
      controller: _scroll,
      itemCount: state.connections.length + (state.hasMore ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (index >= state.connections.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final Connection connection = state.connections[index];
        return UserListTile(
          uid: connection.otherUid,
          onTap: () => context.pushNamed(
            AppRoute.profileDetail.routeName,
            pathParameters: <String, String>{'uid': connection.otherUid},
          ),
        );
      },
    );
  }

  Widget _message({required IconData icon, required String text}) => ListView(
    children: <Widget>[
      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
      Icon(icon, size: 64, color: context.colorScheme.onSurfaceVariant),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    ],
  );
}
