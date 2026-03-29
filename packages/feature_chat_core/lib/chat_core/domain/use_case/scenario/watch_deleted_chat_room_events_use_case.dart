import 'package:feature_chat_core/chat_core/domain/entity/chat_room_event.dart';
import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';

final class WatchDeletedChatRoomEventsUseCase {
  WatchDeletedChatRoomEventsUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Stream<ChatRoomEvent> call() {
    return _chatRepository.watchDeletedChatRoomEvents();
  }
}
