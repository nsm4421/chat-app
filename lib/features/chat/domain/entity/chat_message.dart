final class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.senderDisplayName,
    this.senderUsername,
    this.senderAvatarUrl,
  });

  final String id;
  final String chatRoomId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? senderDisplayName;
  final String? senderUsername;
  final String? senderAvatarUrl;
}
