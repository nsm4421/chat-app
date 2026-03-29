import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';

final class LeaveGroupChatRoomUseCase {
  LeaveGroupChatRoomUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<void> call(String chatRoomId) async {
    await _chatRepository.leaveChatRoomPresence(chatRoomId);
    await _chatRepository.leaveChatRoom(chatRoomId);
  }
}
