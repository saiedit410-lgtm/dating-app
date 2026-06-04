import 'package:dating_app/features/chat/domain/conversation.dart';
import 'package:dating_app/features/connections/domain/connection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConversationId.between', () {
    test('is symmetric and sorted', () {
      expect(ConversationId.between('a', 'b'), 'a_b');
      expect(ConversationId.between('b', 'a'), 'a_b');
      expect(
        ConversationId.between('z', 'a'),
        ConversationId.between('a', 'z'),
      );
    });

    test('matches the connection id for the same pair (1:1 alignment)', () {
      expect(
        ConversationId.between('user1', 'user2'),
        ConnectionIds.connection('user1', 'user2'),
      );
    });
  });
}
