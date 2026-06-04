import 'package:dating_app/core/firebase/firebase_providers.dart';
import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/chat/data/firestore_chat_repository.dart';
import 'package:dating_app/features/chat/domain/chat_repository.dart';
import 'package:dating_app/features/chat/domain/conversation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_providers.g.dart';

/// The app's [ChatRepository] (Firestore-backed).
@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) =>
    FirestoreChatRepository(ref.watch(firebaseFirestoreProvider));

/// Live list of the signed-in user's conversations (latest activity first).
@riverpod
Stream<List<Conversation>> conversations(Ref ref) {
  final String? me = ref.watch(authStateChangesProvider).value?.uid;
  if (me == null) return Stream<List<Conversation>>.value(<Conversation>[]);
  return ref.watch(chatRepositoryProvider).watchConversations(me);
}
