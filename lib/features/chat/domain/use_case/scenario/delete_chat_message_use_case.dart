import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';

final class DeleteChatMessageUseCase {
  DeleteChatMessageUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<void> call(String chatMessageId) {
    return _chatRepository.deleteChatMessage(chatMessageId);
  }
}
