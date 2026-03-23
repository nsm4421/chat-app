import 'package:domodachi/features/auth/domain/use_case/auth_use_cases.dart';
import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';

final class LeaveGroupChatRoomUseCase {
  LeaveGroupChatRoomUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<void> call(String chatRoomId) async {
    await _chatRepository.leaveChatRoomPresence(chatRoomId);
    await _chatRepository.leaveChatRoom(chatRoomId);
  }
}
