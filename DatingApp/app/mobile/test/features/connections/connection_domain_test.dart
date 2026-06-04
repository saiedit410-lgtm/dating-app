import 'package:dating_app/features/connections/domain/connection.dart';
import 'package:dating_app/features/connections/domain/friend_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConnectionIds', () {
    test('request id is directional', () {
      expect(ConnectionIds.request('a', 'b'), 'a_b');
      expect(ConnectionIds.request('b', 'a'), 'b_a');
    });

    test('connection id is symmetric (sorted)', () {
      expect(ConnectionIds.connection('a', 'b'), 'a_b');
      expect(ConnectionIds.connection('b', 'a'), 'a_b');
      expect(
        ConnectionIds.connection('x', 'a'),
        ConnectionIds.connection('a', 'x'),
      );
    });
  });

  group('RequestStatus.fromName', () {
    test('parses known names and returns null otherwise', () {
      expect(RequestStatus.fromName('pending'), RequestStatus.pending);
      expect(RequestStatus.fromName('accepted'), RequestStatus.accepted);
      expect(RequestStatus.fromName('nope'), isNull);
      expect(RequestStatus.fromName(null), isNull);
    });
  });

  group('FriendRequest.fromMap', () {
    test('maps fields with a pending fallback', () {
      final request = FriendRequest.fromMap('a_b', <String, dynamic>{
        'fromUid': 'a',
        'toUid': 'b',
        'status': 'accepted',
      });
      expect(request.fromUid, 'a');
      expect(request.toUid, 'b');
      expect(request.status, RequestStatus.accepted);
    });
  });

  group('Connection.fromMap', () {
    test('resolves the other user relative to me', () {
      final c = Connection.fromMap('a_b', <String, dynamic>{
        'users': <String>['a', 'b'],
      }, 'a');
      expect(c.otherUid, 'b');

      final c2 = Connection.fromMap('a_b', <String, dynamic>{
        'users': <String>['a', 'b'],
      }, 'b');
      expect(c2.otherUid, 'a');
    });
  });
}
