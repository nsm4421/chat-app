import 'package:feature_chat_core/chat_core/domain/entity/chat_room_member.dart';
import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';

final class FetchChatRoomMembersUseCase {
  FetchChatRoomMembersUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<List<ChatRoomMember>> call({
    required String chatRoomId,
    int limit = 30,
    String? cursor,
  }) {
    return _chatRepository.fetchChatRoomMembers(
      chatRoomId: chatRoomId,
      limit: limit,
      cursor: cursor,
    );
  }
}
