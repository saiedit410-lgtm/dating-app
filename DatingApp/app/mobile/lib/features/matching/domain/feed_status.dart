/// Status of a paginated, ranked feed (Discovery, Nearby, future
/// variants). One enum, one set of states, used by every feed
/// controller.
enum FeedStatus { initial, loading, loadingMore, loaded, error }
