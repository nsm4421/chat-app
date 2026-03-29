import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_room_member_overview_model.freezed.dart';
part 'chat_room_member_overview_model.g.dart';

@JsonSerializable()
@freezed
class ChatRoomMemberOverviewModel with _$ChatRoomMemberOverviewModel {
  const ChatRoomMemberOverviewModel({
    @JsonKey(name: 'chat_room_id') required this.chatRoomId,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'is_host') required this.isHost,
    @JsonKey(name: 'joined_at') required this.joinedAt,
    @JsonKey(name: 'anonymous_index') this.anonymousIndex,
    @JsonKey(name: 'display_name') this.displayName,
    @JsonKey(name: 'username') this.username,
    @JsonKey(name: 'avatar_url') this.avatarUrl,
  });

  factory ChatRoomMemberOverviewModel.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomMemberOverviewModelFromJson(json);

  @override
  final String chatRoomId;

  @override
  final String userId;

  @override
  final bool isHost;

  @override
  final DateTime joinedAt;

  @override
  final int? anonymousIndex;

  @override
  final String? displayName;

  @override
  final String? username;

  @override
  final String? avatarUrl;
}
