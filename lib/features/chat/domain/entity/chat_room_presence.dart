enum ChatRoomPresenceEventType { joined, left }

final class ChatRoomPresence {
  const ChatRoomPresence({
    required this.userId,
    required this.presenceRef,
    this.displayName,
    this.avatarUrl,
    this.onlineAt,
  });

  final String userId;
  final String presenceRef;
  final String? displayName;
  final String? avatarUrl;
  final DateTime? onlineAt;
}

final class ChatRoomPresenceEvent {
  const ChatRoomPresenceEvent({required this.type, required this.presence});

  final ChatRoomPresenceEventType type;
  final ChatRoomPresence presence;
}
