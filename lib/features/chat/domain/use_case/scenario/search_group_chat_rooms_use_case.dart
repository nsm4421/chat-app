import 'package:domodachi/features/chat/domain/entity/chat_room.dart';
import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';

final class SearchGroupChatRoomsUseCase {
  SearchGroupChatRoomsUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<List<ChatRoom>> call({required String query, int limit = 20}) {
    return _chatRepository.searchDiscoverChatRooms(query: query, limit: limit);
  }
}
