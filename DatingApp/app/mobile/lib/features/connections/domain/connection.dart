/// Deterministic document ids for requests and connections.
class ConnectionIds {
  const ConnectionIds._();

  /// Directional request id: `{fromUid}_{toUid}`.
  static String request(String fromUid, String toUid) => '${fromUid}_$toUid';

  /// Symmetric connection id: sorted `{uidA}_{uidB}` (same for both users).
  static String connection(String uidA, String uidB) {
    final List<String> ids = <String>[uidA, uidB]..sort();
    return '${ids[0]}_${ids[1]}';
  }
}

/// An accepted connection (`connections/{connId}`). Holds uid references only.
class Connection {
  const Connection({required this.id, required this.otherUid});

  /// Builds a [Connection] from a doc, resolving the "other" user relative to
  /// [me] from the stored `users` array.
  factory Connection.fromMap(
    String id,
    Map<String, dynamic> data,
    String me,
  ) {
    final List<String> users = ((data['users'] as List<dynamic>?) ?? <dynamic>[])
        .map((dynamic e) => e as String)
        .toList();
    final String other = users.firstWhere(
      (String u) => u != me,
      orElse: () => '',
    );
    return Connection(id: id, otherUid: other);
  }

  final String id;
  final String otherUid;
}
