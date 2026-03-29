import 'package:feature_chat_core/chat_core/domain/entity/chat_room.dart';
import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';

final class GetChatRoomUseCase {
  GetChatRoomUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<ChatRoom?> call(String chatRoomId) {
    return _chatRepository.getChatRoom(chatRoomId);
  }
}
