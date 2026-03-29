import 'package:feature_chat_core/chat_core/domain/entity/chat_room.dart';
import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';

final class SearchGroupChatRoomsUseCase {
  SearchGroupChatRoomsUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<List<ChatRoom>> call({required String query, int limit = 20}) {
    return _chatRepository.searchDiscoverChatRooms(query: query, limit: limit);
  }
}
