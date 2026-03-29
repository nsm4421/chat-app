import 'package:feature_chat_core/chat_core/domain/entity/chat_message.dart';
import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';

final class LikeChatMessageUseCase {
  LikeChatMessageUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<ChatMessage> call(String chatMessageId) {
    return _chatRepository.likeChatMessage(chatMessageId);
  }
}
