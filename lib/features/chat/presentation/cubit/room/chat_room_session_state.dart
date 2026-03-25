import 'package:domodachi/features/chat/domain/entity/chat_room.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room_member.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room_presence.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_room_session_state.freezed.dart';

enum ChatRoomSessionStatus { initial, loading, ready, notFound, failure }

@freezed
class ChatRoomSessionState with _$ChatRoomSessionState {
  const ChatRoomSessionState({
    required this.status,
    this.chatRoomId,
    this.room,
    this.members = const <ChatRoomMember>[],
    this.presences = const <ChatRoomPresence>[],
    this.lastPresenceEvent,
    this.errorMessage,
    this.isMember = false,
    this.isJoining = false,
    this.isLeaving = false,
  });

  factory ChatRoomSessionState.initial() {
    return const ChatRoomSessionState(status: ChatRoomSessionStatus.initial);
  }

  @override
  final ChatRoomSessionStatus status;

  @override
  final String? chatRoomId;

  @override
  final ChatRoom? room;

  @override
  final List<ChatRoomMember> members;

  @override
  final List<ChatRoomPresence> presences;

  @override
  final ChatRoomPresenceEvent? lastPresenceEvent;

  @override
  final String? errorMessage;

  @override
  final bool isMember;

  @override
  final bool isJoining;

  @override
  final bool isLeaving;
}

extension ChatRoomSessionStateX on ChatRoomSessionState {
  bool get isLoading => status == ChatRoomSessionStatus.loading;

  bool get isReady => status == ChatRoomSessionStatus.ready;

  bool get isFailure => status == ChatRoomSessionStatus.failure;

  bool get isNotFound => status == ChatRoomSessionStatus.notFound;

  bool get canJoin =>
      isReady &&
      !isMember &&
      !isJoining &&
      room != null &&
      room!.isGroup &&
      room!.isPublic;

  bool get canLeave =>
      isReady && isMember && !isLeaving && room?.isHost != true;

  bool get canDeleteRoom =>
      isReady && isMember && !isLeaving && room?.isHost == true;
}
