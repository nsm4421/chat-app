import 'package:feature_chat_core/chat_core/domain/entity/chat_room.dart';
import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';

final class FetchDiscoverChatRoomsUseCase {
  FetchDiscoverChatRoomsUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<List<ChatRoom>> call({int limit = 20, String? cursor}) {
    return _chatRepository.fetchDiscoverChatRooms(limit: limit, cursor: cursor);
  }
}
