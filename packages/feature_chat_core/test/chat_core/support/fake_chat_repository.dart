import 'package:feature_chat_core/chat_core/core/value_objects/chat_room_enums.dart';
import 'package:feature_chat_core/chat_core/domain/entity/chat_message.dart';
import 'package:feature_chat_core/chat_core/domain/entity/chat_room_event.dart';
import 'package:feature_chat_core/chat_core/domain/entity/chat_room_member.dart';
import 'package:feature_chat_core/chat_core/domain/entity/chat_room_presence.dart';
import 'package:feature_chat_core/chat_core/domain/entity/chat_room.dart';
import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';

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
  List<ChatRoomEvent> chatRoomEvents = const <ChatRoomEvent>[];
  List<ChatRoomMember> chatRoomMembers = const <ChatRoomMember>[];
  List<ChatRoomPresence> chatRoomPresences = const <ChatRoomPresence>[];
  List<String> recentGroupChatSearchQueries = const <String>[];
  Future<ChatRoom?> Function(String chatRoomId)? getChatRoomHandler;
  Stream<ChatMessage> Function(String chatRoomId)? watchNewChatMessagesHandler;
  Stream<ChatRoomEvent> Function(String chatRoomId)?
  watchNewChatRoomEventsHandler;
  Stream<ChatRoomEvent> Function()? watchDeletedChatRoomEventsHandler;
  Stream<List<ChatRoomMember>> Function(String chatRoomId)?
  watchChatRoomMembersHandler;
  Stream<List<ChatRoomPresence>> Function(String chatRoomId)?
  watchChatRoomPresenceHandler;
  Stream<ChatRoomPresenceEvent> Function(String chatRoomId)?
  watchChatRoomPresenceEventsHandler;
  Future<void> Function(String chatRoomId)? joinChatRoomHandler;
  Future<void> Function(String chatRoomId)? leaveChatRoomHandler;
  Future<ChatRoom> Function(String otherUserId)?
  createOrGetPrivateChatRoomHandler;
  Future<void> Function(String chatRoomId)? enterChatRoomPresenceHandler;
  Future<void> Function(String chatRoomId)? leaveChatRoomPresenceHandler;
  Future<ChatMessage> Function({
    required String chatRoomId,
    required String content,
  })?
  sendChatMessageHandler;
  Future<ChatMessage> Function(String chatMessageId)? likeChatMessageHandler;
  Future<ChatMessage> Function(String chatMessageId)? unlikeChatMessageHandler;
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
  Future<List<ChatRoom>> searchDiscoverChatRooms({
    required String query,
    int limit = 20,
  }) async => const [];

  @override
  Future<List<String>> fetchRecentGroupChatSearchQueries() async =>
      recentGroupChatSearchQueries;

  @override
  Future<void> saveRecentGroupChatSearchQuery(String query) async {
    recentGroupChatSearchQueries = [
      query,
      ...recentGroupChatSearchQueries.where((item) => item != query),
    ];
  }

  @override
  Future<void> deleteRecentGroupChatSearchQuery(String query) async {
    recentGroupChatSearchQueries = recentGroupChatSearchQueries
        .where((item) => item != query)
        .toList(growable: false);
  }

  @override
  Future<List<ChatMessage>> fetchChatMessages({
    required String chatRoomId,
    int limit = 50,
    String? cursor,
  }) async => chatMessages;

  @override
  Future<List<ChatRoomEvent>> fetchChatRoomEvents({
    required String chatRoomId,
    int limit = 50,
    String? cursor,
  }) async => chatRoomEvents;

  @override
  Future<ChatRoom?> getChatRoom(String chatRoomId) async {
    return getChatRoomHandler?.call(chatRoomId) ?? currentRoom;
  }

  @override
  Future<ChatRoom> createOrGetPrivateChatRoom(String otherUserId) async {
    return createOrGetPrivateChatRoomHandler!.call(otherUserId);
  }

  @override
  Stream<ChatRoomEvent> watchDeletedChatRoomEvents() {
    return watchDeletedChatRoomEventsHandler?.call() ?? const Stream.empty();
  }

  @override
  Stream<ChatMessage> watchNewChatMessages({required String chatRoomId}) {
    return watchNewChatMessagesHandler?.call(chatRoomId) ??
        const Stream.empty();
  }

  @override
  Stream<ChatRoomEvent> watchNewChatRoomEvents({required String chatRoomId}) {
    return watchNewChatRoomEventsHandler?.call(chatRoomId) ??
        const Stream.empty();
  }

  @override
  Stream<List<ChatRoomMember>> watchChatRoomMembers({
    required String chatRoomId,
  }) {
    return watchChatRoomMembersHandler?.call(chatRoomId) ??
        Stream<List<ChatRoomMember>>.value(chatRoomMembers);
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
  Future<ChatMessage> likeChatMessage(String chatMessageId) async {
    return likeChatMessageHandler!.call(chatMessageId);
  }

  @override
  Future<ChatMessage> unlikeChatMessage(String chatMessageId) async {
    return unlikeChatMessageHandler!.call(chatMessageId);
  }

  @override
  Future<void> deleteChatMessage(String chatMessageId) async {}

  @override
  Future<void> enterChatRoomPresence(String chatRoomId) async {
    await enterChatRoomPresenceHandler?.call(chatRoomId);
  }

  @override
  Future<void> leaveChatRoomPresence(String chatRoomId) async {
    await leaveChatRoomPresenceHandler?.call(chatRoomId);
  }

  @override
  Future<List<ChatRoomMember>> fetchChatRoomMembers({
    required String chatRoomId,
    int limit = 30,
    String? cursor,
  }) async => chatRoomMembers;

  @override
  Future<ChatRoomMember?> getChatRoomMember({
    required String chatRoomId,
    required String userId,
  }) async {
    for (final member in chatRoomMembers) {
      if (member.chatRoomId == chatRoomId && member.userId == userId) {
        return member;
      }
    }
    return null;
  }

  @override
  Future<bool> isChatRoomMember({
    required String chatRoomId,
    required String userId,
  }) async {
    return chatRoomMembers.any(
      (member) => member.chatRoomId == chatRoomId && member.userId == userId,
    );
  }

  @override
  Future<void> joinChatRoom(String chatRoomId) async {
    await joinChatRoomHandler?.call(chatRoomId);
  }

  @override
  Future<void> leaveChatRoom(String chatRoomId) async {
    await leaveChatRoomHandler?.call(chatRoomId);
  }

  @override
  Future<void> deleteChatRoom(String chatRoomId) async {}
}
