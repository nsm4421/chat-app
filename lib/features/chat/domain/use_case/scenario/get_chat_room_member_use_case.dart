import 'package:domodachi/features/chat/domain/entity/chat_room_member.dart';
import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';

final class GetChatRoomMemberUseCase {
  GetChatRoomMemberUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<ChatRoomMember?> call({
    required String chatRoomId,
    required String userId,
  }) {
    return _chatRepository.getChatRoomMember(
      chatRoomId: chatRoomId,
      userId: userId,
    );
  }
}
