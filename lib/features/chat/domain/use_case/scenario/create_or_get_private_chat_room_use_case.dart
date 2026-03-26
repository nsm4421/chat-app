import 'package:domodachi/features/chat/domain/entity/chat_room.dart';
import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';

final class CreateOrGetPrivateChatRoomUseCase {
  CreateOrGetPrivateChatRoomUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<ChatRoom> call(String otherUserId) {
    return _chatRepository.createOrGetPrivateChatRoom(otherUserId);
  }
}
