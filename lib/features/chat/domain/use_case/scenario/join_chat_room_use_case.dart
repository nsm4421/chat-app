import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';

final class JoinChatRoomUseCase {
  JoinChatRoomUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<void> call(String chatRoomId) {
    return _chatRepository.joinChatRoom(chatRoomId);
  }
}
