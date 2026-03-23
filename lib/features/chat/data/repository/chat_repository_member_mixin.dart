part of 'chat_repository_impl.dart';

mixin _ChatMemberRepositoryMixin on ChatRepositoryErrorHandler {
  ChatRoomMemberDataSource get _chatRoomMemberDataSource;

  Stream<List<ChatRoomMember>> watchChatRoomMembers({
    required String chatRoomId,
  }) {
    return _chatRoomMemberDataSource
        .watchMembers(chatRoomId: chatRoomId)
        .map(
          (members) => members
              .map((member) => member.toChatRoomMember())
              .toList(growable: false),
        )
        .transform(
          StreamTransformer<
            List<ChatRoomMember>,
            List<ChatRoomMember>
          >.fromHandlers(
            handleError: (error, stackTrace, sink) {
              if (error is ChatFailure) {
                sink.addError(error, stackTrace);
                return;
              }

              if (error is ChatDataException) {
                sink.addError(
                  ChatFailure(mapChatError(error.message)),
                  stackTrace,
                );
                return;
              }

              sink.addError(
                const ChatFailure('실시간 멤버 목록을 불러오지 못했어요. 잠시 후 다시 시도해 주세요.'),
                stackTrace,
              );
            },
          ),
        );
  }

  Future<List<ChatRoomMember>> fetchChatRoomMembers({
    required String chatRoomId,
    int limit = 30,
    String? cursor,
  }) async {
    return guardChatRequest(() async {
      final members = await _chatRoomMemberDataSource.fetchMembers(
        chatRoomId: chatRoomId,
        limit: limit,
        cursor: cursor,
      );

      return members
          .map((member) => member.toChatRoomMember())
          .toList(growable: false);
    }, fallbackMessage: '채팅방 멤버를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  Future<ChatRoomMember?> getChatRoomMember({
    required String chatRoomId,
    required String userId,
  }) async {
    return guardChatRequest(() async {
      final member = await _chatRoomMemberDataSource.getMember(
        chatRoomId: chatRoomId,
        userId: userId,
      );

      return member?.toChatRoomMember();
    }, fallbackMessage: '멤버 정보를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  Future<bool> isChatRoomMember({
    required String chatRoomId,
    required String userId,
  }) async {
    return guardChatRequest(() async {
      return _chatRoomMemberDataSource.isMember(
        chatRoomId: chatRoomId,
        userId: userId,
      );
    }, fallbackMessage: '멤버 여부를 확인하지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  Future<void> joinChatRoom(String chatRoomId) async {
    await guardChatRequest(() async {
      await _chatRoomMemberDataSource.join(chatRoomId);
    }, fallbackMessage: '채팅방에 참여하지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  Future<void> leaveChatRoom(String chatRoomId) async {
    await guardChatRequest(() async {
      await _chatRoomMemberDataSource.leave(chatRoomId);
    }, fallbackMessage: '채팅방에서 나가지 못했어요. 잠시 후 다시 시도해 주세요.');
  }
}
