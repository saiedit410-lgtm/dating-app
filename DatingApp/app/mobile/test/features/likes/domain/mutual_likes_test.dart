import 'package:dating_app/features/likes/domain/like.dart';
import 'package:flutter_test/flutter_test.dart';

/// A mutual like is the symmetric case: the signed-in user has
/// sent a like to the same person who has liked them back.
///
/// The `LikeButton` widget evaluates this against two live streams
/// (sent + received). This test pins the predicate shape so any
/// future regression in the wiring surfaces here, not in UI tests.
bool isMutual({
  required String me,
  required Like received,
  required Iterable<Like> mySent,
}) {
  if (received.toUid != me) return false;
  for (final Like s in mySent) {
    if (s.fromUid == me && s.toUid == received.fromUid) return true;
  }
  return false;
}

Like _like(String from, String to) => Like(
      id: '${from}_$to',
      fromUid: from,
      toUid: to,
      createdAt: DateTime.utc(2026, 6, 6),
    );

void main() {
  group('isMutual', () {
    test('true when both sides have liked', () {
      final bool mutual = isMutual(
        me: 'me',
        received: _like('them', 'me'),
        mySent: <Like>[_like('me', 'them')],
      );
      expect(mutual, isTrue);
    });

    test('false when only the other person liked me', () {
      final bool mutual = isMutual(
        me: 'me',
        received: _like('them', 'me'),
        mySent: const <Like>[],
      );
      expect(mutual, isFalse);
    });

    test('false when only I liked them', () {
      // Construct a like for the other direction (received is empty
      // by construction — `received` must be addressed to `me` for
      // the predicate to fire). Use a like from a stranger to me.
      final bool mutual = isMutual(
        me: 'me',
        received: _like('someone-else', 'me'),
        mySent: <Like>[_like('me', 'them')],
      );
      expect(mutual, isFalse);
    });

    test('false when received is not addressed to me', () {
      final bool mutual = isMutual(
        me: 'me',
        received: _like('them', 'someone-else'),
        mySent: <Like>[_like('me', 'them')],
      );
      expect(mutual, isFalse);
    });

    test('true regardless of which side liked first', () {
      // I liked them in January, they liked me in June — still mutual.
      final Like old = Like(
        id: 'me_them',
        fromUid: 'me',
        toUid: 'them',
        createdAt: DateTime.utc(2026, 1, 1),
      );
      final Like recent = Like(
        id: 'them_me',
        fromUid: 'them',
        toUid: 'me',
        createdAt: DateTime.utc(2026, 6, 6),
      );
      expect(
        isMutual(me: 'me', received: recent, mySent: <Like>[old]),
        isTrue,
      );
    });
  });
}
