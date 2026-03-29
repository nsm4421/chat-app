import 'package:feature_chat_core/chat_core/domain/entity/chat_room_presence.dart';
import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';

final class WatchChatRoomPresenceEventsUseCase {
  WatchChatRoomPresenceEventsUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Stream<ChatRoomPresenceEvent> call({required String chatRoomId}) {
    return _chatRepository.watchChatRoomPresenceEvents(chatRoomId: chatRoomId);
  }
}
