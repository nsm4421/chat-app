final class ChatRoomMember {
  const ChatRoomMember({
    required this.chatRoomId,
    required this.userId,
    required this.isHost,
    required this.joinedAt,
    this.anonymousIndex,
    this.displayName,
    this.username,
    this.avatarUrl,
  });

  final String chatRoomId;
  final String userId;
  final bool isHost;
  final DateTime joinedAt;
  final int? anonymousIndex;

  final String? displayName;
  final String? username;
  final String? avatarUrl;
}
