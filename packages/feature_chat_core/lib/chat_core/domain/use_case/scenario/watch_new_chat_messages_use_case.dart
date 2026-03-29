import 'package:feature_chat_core/chat_core/domain/entity/chat_message.dart';
import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';

final class WatchNewChatMessagesUseCase {
  WatchNewChatMessagesUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Stream<ChatMessage> call({required String chatRoomId}) {
    return _chatRepository.watchNewChatMessages(chatRoomId: chatRoomId);
  }
}
