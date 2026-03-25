import 'package:domodachi/features/chat/domain/entity/chat_room_member.dart';
import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';

final class WatchChatRoomMembersUseCase {
  WatchChatRoomMembersUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Stream<List<ChatRoomMember>> call({required String chatRoomId}) {
    return _chatRepository.watchChatRoomMembers(chatRoomId: chatRoomId);
  }
}
