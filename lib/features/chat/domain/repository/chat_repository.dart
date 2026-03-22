import 'package:domodachi/features/chat/domain/entity/chat_message.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room_presence.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room.dart';
import 'package:domodachi/features/chat/core/value_objects/chat_room_enums.dart';

abstract class ChatRepository {
  // Drafts
  Future<ChatRoom?> getDraftChatRoom();

  Future<void> deleteDraftChatRoom();

  // Room reads
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

  // Message reads
  Future<List<ChatMessage>> fetchChatMessages({
    required String chatRoomId,
    int limit = 50,
    String? cursor,
  });

  Stream<ChatMessage> watchNewChatMessages({required String chatRoomId});

  // Presence reads
  Stream<List<ChatRoomPresence>> watchChatRoomPresence({
    required String chatRoomId,
  });

  Stream<ChatRoomPresenceEvent> watchChatRoomPresenceEvents({
    required String chatRoomId,
  });

  // Room writes
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

  // Message writes
  Future<ChatMessage> sendChatMessage({
    required String chatRoomId,
    required String content,
  });

  Future<void> deleteChatMessage(String chatMessageId);

  // Presence writes
  Future<void> enterChatRoomPresence({
    required String chatRoomId,
    required String userId,
    String? displayName,
    String? avatarUrl,
  });

  Future<void> leaveChatRoomPresence({required String chatRoomId});

  // Room deletion
  Future<void> deleteChatRoom(String chatRoomId);
}
