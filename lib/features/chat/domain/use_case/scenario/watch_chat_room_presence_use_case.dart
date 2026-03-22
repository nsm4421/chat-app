import 'package:domodachi/features/chat/domain/entity/chat_room_presence.dart';
import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';

final class WatchChatRoomPresenceUseCase {
  WatchChatRoomPresenceUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Stream<List<ChatRoomPresence>> call({required String chatRoomId}) {
    return _chatRepository.watchChatRoomPresence(chatRoomId: chatRoomId);
  }
}
