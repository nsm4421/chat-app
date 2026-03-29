import 'package:feature_chat_core/chat_core/domain/entity/chat_room_member.dart';
import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';

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
