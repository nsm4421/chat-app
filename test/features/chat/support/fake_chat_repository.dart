import 'package:domodachi/features/chat/core/value_objects/chat_room_enums.dart';
import 'package:domodachi/features/chat/domain/entity/chat_message.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room_presence.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room.dart';
import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';

class FakeChatRepository implements ChatRepository {
  FakeChatRepository({
    this.currentRoom,
    this.getChatRoomHandler,
    this.saveDraftChatRoomHandler,
    this.createRemoteChatRoomHandler,
    this.updateChatRoomHandler,
  });

  ChatRoom? currentRoom;
  List<ChatMessage> chatMessages = const <ChatMessage>[];
  List<ChatRoomPresence> chatRoomPresences = const <ChatRoomPresence>[];
  Future<ChatRoom?> Function(String chatRoomId)? getChatRoomHandler;
  Stream<ChatMessage> Function(String chatRoomId)? watchNewChatMessagesHandler;
  Stream<List<ChatRoomPresence>> Function(String chatRoomId)?
  watchChatRoomPresenceHandler;
  Stream<ChatRoomPresenceEvent> Function(String chatRoomId)?
  watchChatRoomPresenceEventsHandler;
  Future<void> Function({
    required String chatRoomId,
    required String userId,
    String? displayName,
    String? avatarUrl,
  })?
  enterChatRoomPresenceHandler;
  Future<void> Function({required String chatRoomId})?
  leaveChatRoomPresenceHandler;
  Future<ChatMessage> Function({
    required String chatRoomId,
    required String content,
  })?
  sendChatMessageHandler;
  Future<ChatRoom> Function({
    required ChatRoomType type,
    required int maxParticipants,
    required bool isPublic,
    String? title,
    String? description,
    List<String> tags,
  })?
  saveDraftChatRoomHandler;
  Future<ChatRoom> Function({
    required ChatRoomStatus status,
    required ChatRoomType type,
    required int maxParticipants,
    required bool isPublic,
    String? title,
    String? description,
    List<String> tags,
  })?
  createRemoteChatRoomHandler;
  Future<void> Function({
    required String chatRoomId,
    String? title,
    String? description,
    List<String>? tags,
    int? maxParticipants,
    ChatRoomStatus? status,
    bool? isPublic,
  })?
  updateChatRoomHandler;

  @override
  Future<ChatRoom?> getDraftChatRoom() async => null;

  @override
  Future<void> deleteDraftChatRoom() async {}

  @override
  Future<List<ChatRoom>> fetchDiscoverChatRooms({
    int limit = 20,
    String? cursor,
  }) async => const [];

  @override
  Future<List<ChatRoom>> fetchJoinedChatRooms({
    int limit = 20,
    String? cursor,
    ChatRoomType? type,
  }) async => const [];

  @override
  Future<List<ChatMessage>> fetchChatMessages({
    required String chatRoomId,
    int limit = 50,
    String? cursor,
  }) async => chatMessages;

  @override
  Future<ChatRoom?> getChatRoom(String chatRoomId) async {
    return getChatRoomHandler?.call(chatRoomId) ?? currentRoom;
  }

  @override
  Stream<ChatMessage> watchNewChatMessages({required String chatRoomId}) {
    return watchNewChatMessagesHandler?.call(chatRoomId) ??
        const Stream.empty();
  }

  @override
  Stream<List<ChatRoomPresence>> watchChatRoomPresence({
    required String chatRoomId,
  }) {
    return watchChatRoomPresenceHandler?.call(chatRoomId) ??
        Stream<List<ChatRoomPresence>>.value(chatRoomPresences);
  }

  @override
  Stream<ChatRoomPresenceEvent> watchChatRoomPresenceEvents({
    required String chatRoomId,
  }) {
    return watchChatRoomPresenceEventsHandler?.call(chatRoomId) ??
        const Stream.empty();
  }

  @override
  Future<ChatRoom> saveDraftChatRoom({
    required ChatRoomType type,
    required int maxParticipants,
    required bool isPublic,
    String? title,
    String? description,
    List<String> tags = const <String>[],
  }) async {
    return saveDraftChatRoomHandler!.call(
      type: type,
      maxParticipants: maxParticipants,
      isPublic: isPublic,
      title: title,
      description: description,
      tags: tags,
    );
  }

  @override
  Future<ChatRoom> createRemoteChatRoom({
    required ChatRoomStatus status,
    required ChatRoomType type,
    required int maxParticipants,
    required bool isPublic,
    String? title,
    String? description,
    List<String> tags = const <String>[],
  }) async {
    return createRemoteChatRoomHandler!.call(
      status: status,
      type: type,
      maxParticipants: maxParticipants,
      isPublic: isPublic,
      title: title,
      description: description,
      tags: tags,
    );
  }

  @override
  Future<void> updateChatRoom({
    required String chatRoomId,
    String? title,
    String? description,
    List<String>? tags,
    int? maxParticipants,
    ChatRoomStatus? status,
    bool? isPublic,
  }) async {
    await updateChatRoomHandler?.call(
      chatRoomId: chatRoomId,
      title: title,
      description: description,
      tags: tags,
      maxParticipants: maxParticipants,
      status: status,
      isPublic: isPublic,
    );
  }

  @override
  Future<ChatMessage> sendChatMessage({
    required String chatRoomId,
    required String content,
  }) async {
    return sendChatMessageHandler!.call(
      chatRoomId: chatRoomId,
      content: content,
    );
  }

  @override
  Future<void> deleteChatMessage(String chatMessageId) async {}

  @override
  Future<void> enterChatRoomPresence({
    required String chatRoomId,
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) async {
    await enterChatRoomPresenceHandler?.call(
      chatRoomId: chatRoomId,
      userId: userId,
      displayName: displayName,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<void> leaveChatRoomPresence({required String chatRoomId}) async {
    await leaveChatRoomPresenceHandler?.call(chatRoomId: chatRoomId);
  }

  @override
  Future<void> deleteChatRoom(String chatRoomId) async {}
}
