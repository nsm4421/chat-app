import 'package:domodachi/features/chat/core/value_objects/chat_room_enums.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room.dart';
import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';

final class FetchMyPrivateChatRoomsUseCase {
  FetchMyPrivateChatRoomsUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<List<ChatRoom>> call({int limit = 20, String? cursor}) {
    return _chatRepository.fetchJoinedChatRooms(
      limit: limit,
      cursor: cursor,
      type: ChatRoomType.private,
    );
  }
}
