import 'package:domodachi/features/chat/core/value_objects/chat_room_enums.dart';

final class ChatRoom {
  const ChatRoom({
    required this.id,
    required this.createdBy,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.title,
    this.description,
    this.tags = const <String>[],
    this.maxParticipants = 8,
    this.isPublic = true,
    this.lastMessageAt,
    this.memberCount = 0,
    this.isJoined = false,
    this.isHost = false,
  });

  final String id;
  final String createdBy;
  final ChatRoomType type;
  final String? title;
  final String? description;
  final List<String> tags;
  final int maxParticipants;
  final ChatRoomStatus status;
  final bool isPublic;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int memberCount;
  final bool isJoined;
  final bool isHost;

  bool get isGroup => type == ChatRoomType.group;
  bool get isPrivate => type == ChatRoomType.private;
}
