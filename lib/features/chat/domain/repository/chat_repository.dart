import 'package:domodachi/features/chat/domain/entity/chat_message.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room_event.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room_member.dart';
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

  // Event reads
  Future<List<ChatRoomEvent>> fetchChatRoomEvents({
    required String chatRoomId,
    int limit = 50,
    String? cursor,
  });

  Stream<ChatRoomEvent> watchNewChatRoomEvents({required String chatRoomId});

  Stream<ChatRoomEvent> watchDeletedChatRoomEvents();

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
  Future<void> enterChatRoomPresence(String chatRoomId);

  Future<void> leaveChatRoomPresence(String chatRoomId);

  // Member reads
  Stream<List<ChatRoomMember>> watchChatRoomMembers({
    required String chatRoomId,
  });

  Future<List<ChatRoomMember>> fetchChatRoomMembers({
    required String chatRoomId,
    int limit = 30,
    String? cursor,
  });

  Future<ChatRoomMember?> getChatRoomMember({
    required String chatRoomId,
    required String userId,
  });

  Future<bool> isChatRoomMember({
    required String chatRoomId,
    required String userId,
  });

  // Member writes
  Future<void> joinChatRoom(String chatRoomId);

  Future<void> leaveChatRoom(String chatRoomId);

  // Room deletion
  Future<void> deleteChatRoom(String chatRoomId);
}
