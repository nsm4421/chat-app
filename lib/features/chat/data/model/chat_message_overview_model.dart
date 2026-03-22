import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_overview_model.freezed.dart';
part 'chat_message_overview_model.g.dart';

@JsonSerializable()
@freezed
class ChatMessageOverviewModel with _$ChatMessageOverviewModel {
  const ChatMessageOverviewModel({
    required this.id,
    @JsonKey(name: 'chat_room_id') required this.chatRoomId,
    @JsonKey(name: 'sender_id') required this.senderId,
    this.content = '',
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
    @JsonKey(name: 'sender_display_name') this.senderDisplayName,
    @JsonKey(name: 'sender_username') this.senderUsername,
    @JsonKey(name: 'sender_avatar_url') this.senderAvatarUrl,
  });

  factory ChatMessageOverviewModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageOverviewModelFromJson(json);

  @override
  final String id;

  @override
  final String chatRoomId;

  @override
  final String senderId;

  @override
  final String content;

  @override
  final DateTime createdAt;

  @override
  final DateTime? updatedAt;

  @override
  final String? senderDisplayName;

  @override
  final String? senderUsername;

  @override
  final String? senderAvatarUrl;
}
