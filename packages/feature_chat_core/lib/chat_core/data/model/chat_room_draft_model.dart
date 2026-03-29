import 'package:feature_chat_core/chat_core/core/value_objects/chat_room_enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_room_draft_model.freezed.dart';

part 'chat_room_draft_model.g.dart';

@JsonSerializable()
@freezed
class ChatRoomDraftModel with _$ChatRoomDraftModel {
  const ChatRoomDraftModel({
    required this.type,
    required this.title,
    required this.description,
    this.tags = const <String>[],
    this.maxParticipants = 8,
    this.isPublic = true,
    required this.savedAt,
  });

  factory ChatRoomDraftModel.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomDraftModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRoomDraftModelToJson(this);

  @override
  final ChatRoomType type;

  ChatRoomStatus get status => ChatRoomStatus.draft;

  @override
  final String title;

  @override
  final String description;

  @override
  final List<String> tags;

  @override
  final int maxParticipants;

  @override
  final bool isPublic;

  @override
  final DateTime savedAt;
}
