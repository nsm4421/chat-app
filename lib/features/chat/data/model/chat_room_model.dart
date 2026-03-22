import 'package:domodachi/features/chat/core/value_objects/chat_room_enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_room_model.freezed.dart';
part 'chat_room_model.g.dart';

@JsonSerializable()
@freezed
class ChatRoomModel with _$ChatRoomModel {
  const ChatRoomModel({
    required this.id,
    @JsonKey(name: 'created_by') required this.createdBy,
    required this.type,
    required this.status,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
    this.title,
    this.description,
    @JsonKey(defaultValue: <String>[]) this.tags = const <String>[],
    @JsonKey(name: 'max_participants') this.maxParticipants = 8,
    @JsonKey(name: 'is_public') this.isPublic = true,
    @JsonKey(name: 'last_message_at') this.lastMessageAt,
    @JsonKey(name: 'member_count') this.memberCount = 0,
    @JsonKey(name: 'is_joined') this.isJoined = false,
    @JsonKey(name: 'is_host') this.isHost = false,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomModelFromJson(json);

  @override
  final String id;

  @override
  final String createdBy;

  @override
  final ChatRoomType type;

  @override
  final String? title;

  @override
  final String? description;

  @override
  final List<String> tags;

  @override
  final int maxParticipants;

  @override
  final ChatRoomStatus status;

  @override
  final bool isPublic;

  @override
  final DateTime? lastMessageAt;

  @override
  final DateTime createdAt;

  @override
  final DateTime updatedAt;

  // Query/view results can enrich the base row with membership metadata.
  @override
  final int memberCount;

  @override
  final bool isJoined;

  @override
  final bool isHost;

  bool get isGroup => type == ChatRoomType.group;
  bool get isPrivate => type == ChatRoomType.private;
}
