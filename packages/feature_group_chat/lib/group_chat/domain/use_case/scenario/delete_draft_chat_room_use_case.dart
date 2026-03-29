import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';

final class DeleteDraftChatRoomUseCase {
  DeleteDraftChatRoomUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<void> call() {
    return _chatRepository.deleteDraftChatRoom();
  }
}
