import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';

final class DeleteDraftChatRoomUseCase {
  DeleteDraftChatRoomUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<void> call() {
    return _chatRepository.deleteDraftChatRoom();
  }
}
