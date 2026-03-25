import 'package:domodachi/features/chat/domain/entity/chat_room_event.dart';
import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';

final class WatchNewChatRoomEventsUseCase {
  WatchNewChatRoomEventsUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Stream<ChatRoomEvent> call({required String chatRoomId}) {
    return _chatRepository.watchNewChatRoomEvents(chatRoomId: chatRoomId);
  }
}
