part of 'chat_repository_impl.dart';

mixin _ChatPresenceRepositoryMixin on ChatRepositoryErrorHandler {
  ChatRoomPresenceDataSource get _chatRoomPresenceDataSource;

  Stream<List<ChatRoomPresence>> watchChatRoomPresence({
    required String chatRoomId,
  }) {
    return _chatRoomPresenceDataSource
        .watchPresence(chatRoomId: chatRoomId)
        .map(
          (presences) => presences
              .map((presence) => presence.toChatRoomPresence())
              .toList(growable: false),
        )
        .transform(
          StreamTransformer<
            List<ChatRoomPresence>,
            List<ChatRoomPresence>
          >.fromHandlers(
            handleError: (error, stackTrace, sink) {
              if (error is ChatDataException) {
                sink.addError(
                  ChatFailure(mapChatError(error.message)),
                  stackTrace,
                );
                return;
              }

              sink.addError(
                const ChatFailure('실시간 접속 상태를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.'),
                stackTrace,
              );
            },
          ),
        );
  }

  Stream<ChatRoomPresenceEvent> watchChatRoomPresenceEvents({
    required String chatRoomId,
  }) {
    return _chatRoomPresenceDataSource
        .watchPresenceEvents(chatRoomId: chatRoomId)
        .map((event) => event.toChatRoomPresenceEvent())
        .transform(
          StreamTransformer<
            ChatRoomPresenceEvent,
            ChatRoomPresenceEvent
          >.fromHandlers(
            handleError: (error, stackTrace, sink) {
              if (error is ChatDataException) {
                sink.addError(
                  ChatFailure(mapChatError(error.message)),
                  stackTrace,
                );
                return;
              }

              sink.addError(
                const ChatFailure('실시간 입장 상태를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.'),
                stackTrace,
              );
            },
          ),
        );
  }

  Future<void> enterChatRoomPresence({
    required String chatRoomId,
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) async {
    await guardChatRequest(() async {
      await _chatRoomPresenceDataSource.enter(
        chatRoomId: chatRoomId,
        userId: userId,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
    }, fallbackMessage: '채팅방 접속 상태를 등록하지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  Future<void> leaveChatRoomPresence({required String chatRoomId}) async {
    await guardChatRequest(() async {
      await _chatRoomPresenceDataSource.leave(chatRoomId: chatRoomId);
    }, fallbackMessage: '채팅방 접속 상태를 정리하지 못했어요. 잠시 후 다시 시도해 주세요.');
  }
}
