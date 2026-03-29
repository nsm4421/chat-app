import 'package:feature_chat_core/chat_core/domain/entity/chat_room.dart';
import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';

final class CreateOrGetPrivateChatRoomUseCase {
  CreateOrGetPrivateChatRoomUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<ChatRoom> call(String otherUserId) {
    return _chatRepository.createOrGetPrivateChatRoom(otherUserId);
  }
}
