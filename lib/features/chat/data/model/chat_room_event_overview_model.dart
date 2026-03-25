import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_room_event_overview_model.freezed.dart';
part 'chat_room_event_overview_model.g.dart';

enum ChatRoomEventTypeModel {
  joined,
  left,
  @JsonValue('room_deleted')
  roomDeleted,
}

@JsonSerializable()
@freezed
class ChatRoomEventOverviewModel with _$ChatRoomEventOverviewModel {
  const ChatRoomEventOverviewModel({
    required this.id,
    @JsonKey(name: 'chat_room_id') required this.chatRoomId,
    @JsonKey(name: 'user_id') required this.userId,
    required this.type,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'anonymous_index') this.anonymousIndex,
  });

  factory ChatRoomEventOverviewModel.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomEventOverviewModelFromJson(json);

  @override
  final String id;

  @override
  final String chatRoomId;

  @override
  final String userId;

  @override
  final ChatRoomEventTypeModel type;

  @override
  final DateTime createdAt;

  @override
  final int? anonymousIndex;
}
