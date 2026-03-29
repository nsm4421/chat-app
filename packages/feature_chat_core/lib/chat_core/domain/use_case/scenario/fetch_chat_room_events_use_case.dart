import 'package:feature_chat_core/chat_core/domain/entity/chat_room_event.dart';
import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';

final class FetchChatRoomEventsUseCase {
  FetchChatRoomEventsUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<List<ChatRoomEvent>> call({
    required String chatRoomId,
    int limit = 50,
    String? cursor,
  }) {
    return _chatRepository.fetchChatRoomEvents(
      chatRoomId: chatRoomId,
      limit: limit,
      cursor: cursor,
    );
  }
}
