import 'package:feature_chat_core/chat_core/domain/entity/chat_room_member.dart';
import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';

final class WatchChatRoomMembersUseCase {
  WatchChatRoomMembersUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Stream<List<ChatRoomMember>> call({required String chatRoomId}) {
    return _chatRepository.watchChatRoomMembers(chatRoomId: chatRoomId);
  }
}
