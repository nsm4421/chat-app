import 'package:feature_chat_core/chat_core/core/value_objects/chat_room_enums.dart';
import 'package:feature_chat_core/chat_core/domain/entity/chat_room.dart';
import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';

final class FetchMyGroupChatRoomsUseCase {
  FetchMyGroupChatRoomsUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<List<ChatRoom>> call({int limit = 20, String? cursor}) {
    return _chatRepository.fetchJoinedChatRooms(
      limit: limit,
      cursor: cursor,
      type: ChatRoomType.group,
    );
  }
}
