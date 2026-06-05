import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/features/safety/domain/report.dart';
import 'package:dating_app/features/safety/domain/safety_repository.dart';

/// Firestore-backed blocking + reporting.
///
/// Blocks: `blocks/{blockerUid}_{blockedUid}`.
/// Reports: `reports/{auto}` (write-only for users; admins read via Admin SDK).
class FirestoreSafetyRepository implements SafetyRepository {
  FirestoreSafetyRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _blocks =>
      _firestore.collection('blocks');
  CollectionReference<Map<String, dynamic>> get _reports =>
      _firestore.collection('reports');

  String _blockId(String blocker, String blocked) => '${blocker}_$blocked';

  @override
  Stream<Set<String>> watchBlockedUids(String me) {
    // Combine the latest of both directions into a single set stream.
    final controller = StreamController<Set<String>>();
    Set<String> outgoing = <String>{};
    Set<String> incoming = <String>{};
    void emit() => controller.add(<String>{...outgoing, ...incoming});

    final StreamSubscription<QuerySnapshot<Map<String, dynamic>>> outSub =
        _blocks.where('blockerUid', isEqualTo: me).snapshots().listen((
          QuerySnapshot<Map<String, dynamic>> snap,
        ) {
          outgoing = snap.docs
              .map((d) => d.data()['blockedUid'] as String? ?? '')
              .where((String s) => s.isNotEmpty)
              .toSet();
          emit();
        });
    final StreamSubscription<QuerySnapshot<Map<String, dynamic>>> inSub =
        _blocks.where('blockedUid', isEqualTo: me).snapshots().listen((
          QuerySnapshot<Map<String, dynamic>> snap,
        ) {
          incoming = snap.docs
              .map((d) => d.data()['blockerUid'] as String? ?? '')
              .where((String s) => s.isNotEmpty)
              .toSet();
          emit();
        });

    controller.onCancel = () async {
      await outSub.cancel();
      await inSub.cancel();
    };
    return controller.stream;
  }

  @override
  Future<void> blockUser({
    required String blockerUid,
    required String blockedUid,
  }) => _blocks.doc(_blockId(blockerUid, blockedUid)).set(<String, Object?>{
    'blockerUid': blockerUid,
    'blockedUid': blockedUid,
    'createdAt': FieldValue.serverTimestamp(),
  });

  @override
  Future<void> unblockUser({
    required String blockerUid,
    required String blockedUid,
  }) => _blocks.doc(_blockId(blockerUid, blockedUid)).delete();

  @override
  Future<void> submitReport({
    required String reporterUid,
    required String reportedUid,
    required ReportCategory category,
    required String description,
  }) => _reports.add(<String, Object?>{
    'reporterUid': reporterUid,
    'reportedUid': reportedUid,
    'category': category.name,
    'description': description,
    'status': ReportStatus.open.name,
    'createdAt': FieldValue.serverTimestamp(),
  });
}
