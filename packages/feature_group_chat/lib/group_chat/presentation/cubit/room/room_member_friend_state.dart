import 'package:freezed_annotation/freezed_annotation.dart';

part 'room_member_friend_state.freezed.dart';

enum RoomMemberFriendStatus {
  self,
  canSendRequest,
  requestSent,
  requestReceived,
  friend,
}

@freezed
class RoomMemberFriendRelation with _$RoomMemberFriendRelation {
  const RoomMemberFriendRelation({
    required this.userId,
    required this.status,
    this.requestId,
  });

  @override
  final String userId;

  @override
  final RoomMemberFriendStatus status;

  @override
  final String? requestId;
}

@freezed
class RoomMemberFriendState with _$RoomMemberFriendState {
  const RoomMemberFriendState({
    this.relations = const <String, RoomMemberFriendRelation>{},
    this.processingUserIds = const <String>{},
    this.errorMessage,
    this.noticeMessage,
  });

  factory RoomMemberFriendState.initial() => const RoomMemberFriendState();

  @override
  final Map<String, RoomMemberFriendRelation> relations;

  @override
  final Set<String> processingUserIds;

  @override
  final String? errorMessage;

  @override
  final String? noticeMessage;
}
