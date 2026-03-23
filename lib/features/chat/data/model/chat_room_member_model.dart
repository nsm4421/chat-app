import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_room_member_model.freezed.dart';
part 'chat_room_member_model.g.dart';

@JsonSerializable()
@freezed
class ChatRoomMemberModel with _$ChatRoomMemberModel {
  const ChatRoomMemberModel({
    @JsonKey(name: 'chat_room_id') required this.chatRoomId,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'is_host') required this.isHost,
    @JsonKey(name: 'joined_at') required this.joinedAt,
  });

  factory ChatRoomMemberModel.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomMemberModelFromJson(json);

  @override
  final String chatRoomId;

  @override
  final String userId;

  @override
  final bool isHost;

  @override
  final DateTime joinedAt;
}

