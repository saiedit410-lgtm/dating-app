import 'package:dating_app/features/likes/domain/like.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LikeIds', () {
    test('like id is directional', () {
      expect(LikeIds.like('a', 'b'), 'a_b');
      expect(LikeIds.like('b', 'a'), 'b_a');
      // A->A must not collide with the same user liking themselves
      // (rules forbid it, but the id shape still distinguishes).
      expect(LikeIds.like('a', 'a'), 'a_a');
    });
  });

  group('Like.fromMap', () {
    test('maps fields with safe fallbacks', () {
      final like = Like.fromMap('a_b', <String, dynamic>{
        'fromUid': 'a',
        'toUid': 'b',
        'createdAt': DateTime.utc(2026, 6, 6),
      });
      expect(like.id, 'a_b');
      expect(like.fromUid, 'a');
      expect(like.toUid, 'b');
      expect(like.createdAt, DateTime.utc(2026, 6, 6));
    });

    test('falls back to epoch on missing or non-DateTime createdAt', () {
      final missing = Like.fromMap('a_b', <String, dynamic>{
        'fromUid': 'a',
        'toUid': 'b',
      });
      expect(missing.createdAt, DateTime.fromMillisecondsSinceEpoch(0));

      final notDate = Like.fromMap('a_b', <String, dynamic>{
        'fromUid': 'a',
        'toUid': 'b',
        'createdAt': 'tomorrow',
      });
      expect(notDate.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('handles empty/missing uid fields with empty strings', () {
      final like = Like.fromMap('a_b', <String, dynamic>{});
      expect(like.fromUid, '');
      expect(like.toUid, '');
    });
  });
}
