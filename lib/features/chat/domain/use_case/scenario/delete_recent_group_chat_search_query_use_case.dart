import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';

final class DeleteRecentGroupChatSearchQueryUseCase {
  DeleteRecentGroupChatSearchQueryUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<void> call(String query) {
    return _chatRepository.deleteRecentGroupChatSearchQuery(query);
  }
}
