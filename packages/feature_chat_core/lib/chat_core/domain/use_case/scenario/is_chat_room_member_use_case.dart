import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';

final class IsChatRoomMemberUseCase {
  IsChatRoomMemberUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<bool> call({required String chatRoomId, required String userId}) {
    return _chatRepository.isChatRoomMember(
      chatRoomId: chatRoomId,
      userId: userId,
    );
  }
}
