import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_room_presence_model.freezed.dart';

@freezed
class ChatRoomPresenceModel with _$ChatRoomPresenceModel {
  const ChatRoomPresenceModel({
    required this.userId,
    required this.presenceRef,
    this.displayName,
    this.avatarUrl,
    this.onlineAt,
  });

  @override
  final String userId;

  @override
  final String presenceRef;

  @override
  final String? displayName;

  @override
  final String? avatarUrl;

  @override
  final DateTime? onlineAt;
}
