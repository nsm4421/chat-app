import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';

final class LeaveChatRoomUseCase {
  LeaveChatRoomUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<void> call(String chatRoomId) {
    return _chatRepository.leaveChatRoom(chatRoomId);
  }
}
