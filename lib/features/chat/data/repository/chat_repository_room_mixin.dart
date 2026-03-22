part of 'chat_repository_impl.dart';

mixin _ChatRoomRepositoryMixin on ChatRepositoryErrorHandler {
  ChatRoomDataSource get _chatRoomDataSource;
  ChatRoomDraftLocalDataSource get _chatRoomDraftLocalDataSource;

  Future<ChatRoom?> getDraftChatRoom() async {
    return guardChatRequest(() async {
      final draft = await _chatRoomDraftLocalDataSource.getDraft();
      return draft?.toChatRoom();
    }, fallbackMessage: '임시 저장한 채팅방을 불러오지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  Future<void> deleteDraftChatRoom() async {
    await guardChatRequest(() async {
      await _chatRoomDraftLocalDataSource.deleteDraft();
    }, fallbackMessage: '임시 저장한 채팅방을 삭제하지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  Future<List<ChatRoom>> fetchDiscoverChatRooms({
    int limit = 20,
    String? cursor,
  }) async {
    return guardChatRequest(() async {
      final rooms = await _chatRoomDataSource.fetchDiscoverChatRooms(
        limit: limit,
        cursor: cursor,
      );

      return rooms.map((room) => room.toChatRoom()).toList(growable: false);
    }, fallbackMessage: '채팅방 목록을 불러오지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  Future<List<ChatRoom>> fetchJoinedChatRooms({
    int limit = 20,
    String? cursor,
    ChatRoomType? type,
  }) async {
    return guardChatRequest(() async {
      final rooms = await _chatRoomDataSource.fetchJoinedChatRooms(
        limit: limit,
        cursor: cursor,
        type: type,
      );

      return rooms.map((room) => room.toChatRoom()).toList(growable: false);
    }, fallbackMessage: '참여 중인 채팅방을 불러오지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  Future<ChatRoom?> getChatRoom(String chatRoomId) async {
    return guardChatRequest(() async {
      final room = await _chatRoomDataSource.getChatRoom(chatRoomId);
      return room?.toChatRoom();
    }, fallbackMessage: '채팅방 정보를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  Future<ChatRoom> saveDraftChatRoom({
    required ChatRoomType type,
    required int maxParticipants,
    required bool isPublic,
    String? title,
    String? description,
    List<String> tags = const <String>[],
  }) async {
    return guardChatRequest(() async {
      final draft = ChatRoomDraftModel(
        type: type,
        title: title?.trim() ?? '',
        description: description?.trim() ?? '',
        tags: tags.map((tag) => tag.trim()).toList(growable: false),
        maxParticipants: maxParticipants,
        isPublic: isPublic,
        savedAt: DateTime.now(),
      );

      await _chatRoomDraftLocalDataSource.saveDraft(draft);
      return draft.toChatRoom();
    }, fallbackMessage: '임시 저장하지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  Future<ChatRoom> createRemoteChatRoom({
    required ChatRoomStatus status,
    required ChatRoomType type,
    required int maxParticipants,
    required bool isPublic,
    String? title,
    String? description,
    List<String> tags = const <String>[],
  }) async {
    return guardChatRequest(() async {
      final room = await _chatRoomDataSource.createChatRoom(
        status: status,
        type: type,
        maxParticipants: maxParticipants,
        isPublic: isPublic,
        title: title,
        description: description,
        tags: tags,
      );
      await _chatRoomDraftLocalDataSource.deleteDraft();

      return room.toChatRoom();
    }, fallbackMessage: '채팅방을 만들지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  Future<void> updateChatRoom({
    required String chatRoomId,
    String? title,
    String? description,
    List<String>? tags,
    int? maxParticipants,
    ChatRoomStatus? status,
    bool? isPublic,
  }) async {
    await guardChatRequest(() async {
      await _chatRoomDataSource.updateChatRoom(
        chatRoomId: chatRoomId,
        title: title,
        description: description,
        tags: tags,
        maxParticipants: maxParticipants,
        status: status,
        isPublic: isPublic,
      );
    }, fallbackMessage: '채팅방을 수정하지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  Future<void> deleteChatRoom(String chatRoomId) async {
    await guardChatRequest(() async {
      await _chatRoomDataSource.softDeleteChatRoom(chatRoomId);
    }, fallbackMessage: '채팅방을 삭제하지 못했어요. 잠시 후 다시 시도해 주세요.');
  }
}
