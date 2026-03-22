part of 'chat_repository_impl.dart';

mixin _ChatMessageRepositoryMixin on ChatRepositoryErrorHandler {
  ChatMessageDataSource get _chatMessageDataSource;

  Future<List<ChatMessage>> fetchChatMessages({
    required String chatRoomId,
    int limit = 50,
    String? cursor,
  }) async {
    return guardChatRequest(() async {
      final messages = await _chatMessageDataSource.fetchMessages(
        chatRoomId: chatRoomId,
        limit: limit,
        cursor: cursor,
      );

      return messages
          .map((message) => message.toChatMessage())
          .toList(growable: false);
    }, fallbackMessage: '메시지 목록을 불러오지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  Stream<ChatMessage> watchNewChatMessages({required String chatRoomId}) {
    return _chatMessageDataSource
        .watchNewMessages(chatRoomId: chatRoomId)
        .map((message) => message.toChatMessage())
        .transform(
          StreamTransformer<ChatMessage, ChatMessage>.fromHandlers(
            handleError: (error, stackTrace, sink) {
              if (error is ChatDataException) {
                sink.addError(
                  ChatFailure(mapChatError(error.message)),
                  stackTrace,
                );
                return;
              }

              sink.addError(
                const ChatFailure('실시간 메시지를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.'),
                stackTrace,
              );
            },
          ),
        );
  }

  Future<ChatMessage> sendChatMessage({
    required String chatRoomId,
    required String content,
  }) async {
    return guardChatRequest(() async {
      final message = await _chatMessageDataSource.insert(
        chatRoomId: chatRoomId,
        content: content,
      );

      return message.toChatMessage();
    }, fallbackMessage: '메시지를 전송하지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  Future<void> deleteChatMessage(String chatMessageId) async {
    await guardChatRequest(() async {
      await _chatMessageDataSource.softDelete(chatMessageId: chatMessageId);
    }, fallbackMessage: '메시지를 삭제하지 못했어요. 잠시 후 다시 시도해 주세요.');
  }
}
