import 'package:dating_app/features/likes/domain/profile_visitor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VisitorIds', () {
    test('visit id is directional', () {
      expect(VisitorIds.visit('viewer', 'profile'), 'viewer_profile');
      expect(VisitorIds.visit('profile', 'viewer'), 'profile_viewer');
    });
  });

  group('ProfileVisitor.fromMap', () {
    test('maps fields with safe fallbacks', () {
      final visit = ProfileVisitor.fromMap('v_p', <String, dynamic>{
        'viewerUid': 'v',
        'profileUid': 'p',
        'viewedAt': DateTime.utc(2026, 6, 6),
      });
      expect(visit.id, 'v_p');
      expect(visit.viewerUid, 'v');
      expect(visit.profileUid, 'p');
      expect(visit.viewedAt, DateTime.utc(2026, 6, 6));
    });

    test('falls back to epoch on missing or non-DateTime viewedAt', () {
      final missing = ProfileVisitor.fromMap('v_p', <String, dynamic>{
        'viewerUid': 'v',
        'profileUid': 'p',
      });
      expect(missing.viewedAt, DateTime.fromMillisecondsSinceEpoch(0));

      final notDate = ProfileVisitor.fromMap('v_p', <String, dynamic>{
        'viewerUid': 'v',
        'profileUid': 'p',
        'viewedAt': 'yesterday',
      });
      expect(notDate.viewedAt, DateTime.fromMillisecondsSinceEpoch(0));
    });
  });
}
