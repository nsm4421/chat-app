import 'package:domodachi/features/chat/domain/entity/chat_room_member.dart';
import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';

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
