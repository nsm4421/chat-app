import 'package:domodachi/features/chat/domain/entity/chat_room.dart';
import 'package:domodachi/features/chat/core/value_objects/chat_room_enums.dart';

abstract class ChatRepository {
  Future<ChatRoom?> getDraftChatRoom();

  Future<void> deleteDraftChatRoom();

  Future<List<ChatRoom>> fetchDiscoverChatRooms({
    int limit = 20,
    String? cursor,
  });

  Future<List<ChatRoom>> fetchJoinedChatRooms({
    int limit = 20,
    String? cursor,
    ChatRoomType? type,
  });

  Future<ChatRoom?> getChatRoom(String chatRoomId);

  Future<ChatRoom> saveDraftChatRoom({
    required ChatRoomType type,
    required int maxParticipants,
    required bool isPublic,
    String? title,
    String? description,
    List<String> tags = const <String>[],
  });

  Future<ChatRoom> createRemoteChatRoom({
    required ChatRoomStatus status,
    required ChatRoomType type,
    required int maxParticipants,
    required bool isPublic,
    String? title,
    String? description,
    List<String> tags = const <String>[],
  });

  Future<void> updateChatRoom({
    required String chatRoomId,
    String? title,
    String? description,
    List<String>? tags,
    int? maxParticipants,
    ChatRoomStatus? status,
    bool? isPublic,
  });

  Future<void> joinChatRoom(String chatRoomId);

  Future<void> leaveChatRoom(String chatRoomId);

  Future<void> deleteChatRoom(String chatRoomId);
}
