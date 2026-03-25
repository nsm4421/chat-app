import 'package:domodachi/features/chat/domain/entity/chat_room_event.dart';
import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';

final class WatchDeletedChatRoomEventsUseCase {
  WatchDeletedChatRoomEventsUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Stream<ChatRoomEvent> call() {
    return _chatRepository.watchDeletedChatRoomEvents();
  }
}
