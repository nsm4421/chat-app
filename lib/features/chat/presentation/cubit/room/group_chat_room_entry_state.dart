import 'package:domodachi/features/chat/domain/entity/chat_room.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_chat_room_entry_state.freezed.dart';

enum GroupChatRoomEntryStatus {
  initial,
  loading,
  preview,
  joined,
  full,
  closed,
  restricted,
  notFound,
  failure,
}

@freezed
class GroupChatRoomEntryState with _$GroupChatRoomEntryState {
  const GroupChatRoomEntryState({
    required this.status,
    this.room,
    this.errorMessage,
    this.isJoining = false,
  });

  factory GroupChatRoomEntryState.initial() {
    return const GroupChatRoomEntryState(
      status: GroupChatRoomEntryStatus.initial,
    );
  }

  @override
  final GroupChatRoomEntryStatus status;

  @override
  final ChatRoom? room;

  @override
  final String? errorMessage;

  @override
  final bool isJoining;
}

extension GroupChatRoomEntryStateX on GroupChatRoomEntryState {
  bool get isLoading => status == GroupChatRoomEntryStatus.loading;

  bool get isJoined => status == GroupChatRoomEntryStatus.joined;

  bool get canJoin => status == GroupChatRoomEntryStatus.preview;
}
