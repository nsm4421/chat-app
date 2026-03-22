import 'package:domodachi/features/chat/core/value_objects/chat_room_enums.dart';
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
  Future<ChatRoom?> Function(String chatRoomId)? getChatRoomHandler;
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
  Future<ChatRoom?> getChatRoom(String chatRoomId) async {
    return getChatRoomHandler?.call(chatRoomId) ?? currentRoom;
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
  Future<void> joinChatRoom(String chatRoomId) async {}

  @override
  Future<void> leaveChatRoom(String chatRoomId) async {}

  @override
  Future<void> deleteChatRoom(String chatRoomId) async {}
}
