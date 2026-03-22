import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';

final class EnterChatRoomPresenceUseCase {
  EnterChatRoomPresenceUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<void> call({
    required String chatRoomId,
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) {
    return _chatRepository.enterChatRoomPresence(
      chatRoomId: chatRoomId,
      userId: userId,
      displayName: displayName,
      avatarUrl: avatarUrl,
    );
  }
}
