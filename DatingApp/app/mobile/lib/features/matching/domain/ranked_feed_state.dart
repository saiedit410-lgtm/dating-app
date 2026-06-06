import 'package:dating_app/features/matching/domain/feed_status.dart';

/// Generic, paginated, ranked feed state shared by every feed
/// controller. `T` is the per-item shape (`ScoredProfile` for the
/// matching feeds; `NearbyProfile` for the legacy nearby shape if
/// a future controller needs it).
class RankedFeedState<T> {
  const RankedFeedState({
    this.items = const <Never>[],
    this.status = FeedStatus.initial,
    this.hasMore = true,
    this.cursor,
    this.errorMessage,
  });

  /// Convenience: typed empty default for `T` is impossible at
  /// compile time, so controllers fill in the right list type at
  /// the call site (`const <ScoredProfile>[]`).
  // ignore: prefer_initializing_formals
  final List<T> items;
  final FeedStatus status;
  final bool hasMore;
  final Object? cursor;
  final String? errorMessage;

  bool get isInitialLoading =>
      status == FeedStatus.loading && items.isEmpty;
  bool get isLoadingMore => status == FeedStatus.loadingMore;

  RankedFeedState<T> copyWith({
    List<T>? items,
    FeedStatus? status,
    bool? hasMore,
    Object? cursor,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RankedFeedState<T>(
      items: items ?? this.items,
      status: status ?? this.status,
      hasMore: hasMore ?? this.hasMore,
      cursor: cursor ?? this.cursor,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
