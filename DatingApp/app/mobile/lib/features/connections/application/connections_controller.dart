import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/connections/application/connection_providers.dart';
import 'package:dating_app/features/connections/domain/connection.dart';
import 'package:dating_app/features/connections/domain/connection_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connections_controller.g.dart';

enum ConnectionsStatus { initial, loading, loadingMore, loaded, error }

/// Paginated accepted-connections feed state.
class ConnectionsState {
  const ConnectionsState({
    this.connections = const <Connection>[],
    this.status = ConnectionsStatus.initial,
    this.hasMore = true,
    this.cursor,
  });

  final List<Connection> connections;
  final ConnectionsStatus status;
  final bool hasMore;
  final Object? cursor;

  bool get isInitialLoading =>
      status == ConnectionsStatus.loading && connections.isEmpty;

  ConnectionsState copyWith({
    List<Connection>? connections,
    ConnectionsStatus? status,
    bool? hasMore,
    Object? cursor,
  }) => ConnectionsState(
    connections: connections ?? this.connections,
    status: status ?? this.status,
    hasMore: hasMore ?? this.hasMore,
    cursor: cursor ?? this.cursor,
  );
}

/// Loads the signed-in user's accepted connections with cursor pagination.
@riverpod
class ConnectionsController extends _$ConnectionsController {
  static const int _pageSize = 20;

  @override
  ConnectionsState build() => const ConnectionsState();

  Future<void> loadInitial() async {
    if (state.status != ConnectionsStatus.initial) return;
    await _fetch(reset: true);
  }

  Future<void> refresh() => _fetch(reset: true);

  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.status == ConnectionsStatus.loading ||
        state.status == ConnectionsStatus.loadingMore) {
      return;
    }
    await _fetch(reset: false);
  }

  Future<void> _fetch({required bool reset}) async {
    final String? me = ref.read(authStateChangesProvider).value?.uid;
    if (me == null) return;

    state = state.copyWith(
      status: reset
          ? ConnectionsStatus.loading
          : ConnectionsStatus.loadingMore,
      connections: reset ? <Connection>[] : null,
    );

    try {
      final ConnectionPage page = await ref
          .read(connectionRepositoryProvider)
          .fetchConnections(
            me: me,
            cursor: reset ? null : state.cursor,
            limit: _pageSize,
          );
      final List<Connection> merged = reset
          ? page.connections
          : <Connection>[...state.connections, ...page.connections];
      state = ConnectionsState(
        connections: merged,
        status: ConnectionsStatus.loaded,
        hasMore: page.hasMore,
        cursor: page.nextCursor,
      );
    } catch (_) {
      state = state.copyWith(status: ConnectionsStatus.error);
    }
  }
}
