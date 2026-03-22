import 'package:domodachi/features/chat/domain/entity/chat_room.dart';
import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';

final class GetChatRoomUseCase {
  GetChatRoomUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<ChatRoom?> call(String chatRoomId) {
    return _chatRepository.getChatRoom(chatRoomId);
  }
}
