enum ChatRoomEventType { joined, left, roomDeleted }

final class ChatRoomEvent {
  const ChatRoomEvent({
    required this.id,
    required this.chatRoomId,
    required this.userId,
    required this.type,
    required this.createdAt,
    this.anonymousIndex,
  });

  final String id;
  final String chatRoomId;
  final String userId;
  final ChatRoomEventType type;
  final DateTime createdAt;
  final int? anonymousIndex;
}
