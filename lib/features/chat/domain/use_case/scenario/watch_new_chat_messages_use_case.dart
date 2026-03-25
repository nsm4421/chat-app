import 'package:domodachi/features/chat/domain/entity/chat_message.dart';
import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';

final class WatchNewChatMessagesUseCase {
  WatchNewChatMessagesUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Stream<ChatMessage> call({required String chatRoomId}) {
    return _chatRepository.watchNewChatMessages(chatRoomId: chatRoomId);
  }
}
