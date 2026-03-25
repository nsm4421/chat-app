part of 'chat_repository_impl.dart';

mixin _ChatEventRepositoryMixin on ChatRepositoryErrorHandler {
  ChatRoomEventDataSource get _chatRoomEventDataSource;

  Future<List<ChatRoomEvent>> fetchChatRoomEvents({
    required String chatRoomId,
    int limit = 50,
    String? cursor,
  }) async {
    return guardChatRequest(() async {
      final events = await _chatRoomEventDataSource.fetchEvents(
        chatRoomId: chatRoomId,
        limit: limit,
        cursor: cursor,
      );

      return events
          .map((event) => event.toChatRoomEvent())
          .toList(growable: false);
    }, fallbackMessage: '채팅 이벤트를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  Stream<ChatRoomEvent> watchNewChatRoomEvents({required String chatRoomId}) {
    return _chatRoomEventDataSource
        .watchNewEvents(chatRoomId: chatRoomId)
        .map((event) => event.toChatRoomEvent())
        .transform(
          StreamTransformer<ChatRoomEvent, ChatRoomEvent>.fromHandlers(
            handleError: (error, stackTrace, sink) {
              if (error is ChatDataException) {
                sink.addError(
                  ChatFailure(mapChatError(error.message)),
                  stackTrace,
                );
                return;
              }

              sink.addError(
                const ChatFailure('실시간 채팅 이벤트를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.'),
                stackTrace,
              );
            },
          ),
        );
  }

  Stream<ChatRoomEvent> watchDeletedChatRoomEvents() {
    return _chatRoomEventDataSource
        .watchDeletedRoomEvents()
        .map((event) => event.toChatRoomEvent())
        .transform(
          StreamTransformer<ChatRoomEvent, ChatRoomEvent>.fromHandlers(
            handleError: (error, stackTrace, sink) {
              if (error is ChatDataException) {
                sink.addError(
                  ChatFailure(mapChatError(error.message)),
                  stackTrace,
                );
                return;
              }

              sink.addError(
                const ChatFailure('실시간 채팅 이벤트를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.'),
                stackTrace,
              );
            },
          ),
        );
  }
}
