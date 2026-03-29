import 'package:feature_chat_core/chat_core/domain/entity/chat_message.dart';
import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';

final class FetchChatMessagesUseCase {
  FetchChatMessagesUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<List<ChatMessage>> call({
    required String chatRoomId,
    int limit = 50,
    String? cursor,
  }) {
    return _chatRepository.fetchChatMessages(
      chatRoomId: chatRoomId,
      limit: limit,
      cursor: cursor,
    );
  }
}
