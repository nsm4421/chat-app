import 'package:domodachi/features/chat/domain/entity/chat_message.dart';
import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';

final class SendChatMessageUseCase {
  SendChatMessageUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<ChatMessage> call({
    required String chatRoomId,
    required String content,
  }) {
    return _chatRepository.sendChatMessage(
      chatRoomId: chatRoomId,
      content: content,
    );
  }
}
