import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_model.freezed.dart';
part 'chat_message_model.g.dart';

@JsonSerializable()
@freezed
class ChatMessageModel with _$ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    @JsonKey(name: 'chat_room_id') required this.chatRoomId,
    @JsonKey(name: 'sender_id') required this.senderId,
    this.content = '',
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);

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
}
