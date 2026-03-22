import 'package:domodachi/features/chat/domain/entity/chat_room_presence.dart';
import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';

final class WatchChatRoomPresenceEventsUseCase {
  WatchChatRoomPresenceEventsUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Stream<ChatRoomPresenceEvent> call({required String chatRoomId}) {
    return _chatRepository.watchChatRoomPresenceEvents(chatRoomId: chatRoomId);
  }
}
