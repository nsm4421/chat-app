import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';

final class DeleteChatRoomUseCase {
  DeleteChatRoomUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<void> call(String chatRoomId) {
    return _chatRepository.deleteChatRoom(chatRoomId);
  }
}
