import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';

final class JoinGroupChatRoomUseCase {
  JoinGroupChatRoomUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<void> call(String chatRoomId) async {
    await _chatRepository.joinChatRoom(chatRoomId);

    await _chatRepository.enterChatRoomPresence(chatRoomId);
  }
}
