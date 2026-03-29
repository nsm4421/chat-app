import 'package:feature_chat_core/chat_core/domain/entity/chat_room_event.dart';
import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';

final class WatchNewChatRoomEventsUseCase {
  WatchNewChatRoomEventsUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Stream<ChatRoomEvent> call({required String chatRoomId}) {
    return _chatRepository.watchNewChatRoomEvents(chatRoomId: chatRoomId);
  }
}
