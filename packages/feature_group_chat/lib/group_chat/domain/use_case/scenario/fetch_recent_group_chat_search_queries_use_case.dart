import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';

final class FetchRecentGroupChatSearchQueriesUseCase {
  FetchRecentGroupChatSearchQueriesUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<List<String>> call() {
    return _chatRepository.fetchRecentGroupChatSearchQueries();
  }
}
