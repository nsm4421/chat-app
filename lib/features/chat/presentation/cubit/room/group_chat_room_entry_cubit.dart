import 'package:domodachi/core/error/failure.dart';
import 'package:domodachi/features/chat/core/value_objects/chat_room_enums.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room.dart';
import 'package:domodachi/features/chat/domain/use_case/chat_use_cases.dart';
import 'package:domodachi/features/chat/presentation/cubit/room/group_chat_room_entry_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class GroupChatRoomEntryCubit extends Cubit<GroupChatRoomEntryState> {
  GroupChatRoomEntryCubit(this._chatUseCases)
    : super(GroupChatRoomEntryState.initial());

  final ChatUseCases _chatUseCases;

  String? _chatRoomId;

  Future<void> load(String chatRoomId) async {
    _chatRoomId = chatRoomId;
    emit(
      state.copyWith(
        status: GroupChatRoomEntryStatus.loading,
        errorMessage: null,
        isJoining: false,
      ),
    );

    await _resolve(chatRoomId);
  }

  Future<void> retry() async {
    final chatRoomId = _chatRoomId;
    if (chatRoomId == null) {
      return;
    }

    await load(chatRoomId);
  }

  Future<void> join() async {
    final room = state.room;
    if (room == null || !state.canJoin || state.isJoining) {
      return;
    }

    emit(
      state.copyWith(
        isJoining: true,
      ),
    );

    try {
      await _chatUseCases.joinGroupChatRoom(room.id);

      emit(
        GroupChatRoomEntryState(
          status: GroupChatRoomEntryStatus.joined,
          room: room,
        ),
      );
    } on Failure catch (error) {
      emit(
        GroupChatRoomEntryState(
          status: GroupChatRoomEntryStatus.failure,
          room: room,
          errorMessage: error.message,
          isJoining: false,
        ),
      );
    } catch (_) {
      emit(
        GroupChatRoomEntryState(
          status: GroupChatRoomEntryStatus.failure,
          room: room,
          errorMessage: '채팅방 참여에 실패했어요. 잠시 후 다시 시도해 주세요.',
          isJoining: false,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    final chatRoomId = _chatRoomId;
    if (chatRoomId != null && state.isJoined) {
      try {
        await _chatUseCases.leaveGroupChatRoom(chatRoomId);
      } catch (_) {
        // Leave failures should not crash the app during navigation.
      }
    }
    return super.close();
  }

  Future<void> _resolve(String chatRoomId, {String? actionErrorMessage}) async {
    try {
      final room = await _chatUseCases.getChatRoom(chatRoomId);
      if (room == null || !room.isGroup) {
        emit(
          GroupChatRoomEntryState(
            status: GroupChatRoomEntryStatus.notFound,
            errorMessage: actionErrorMessage,
          ),
        );
        return;
      }

      emit(_resolveState(room, actionErrorMessage: actionErrorMessage));
    } on Failure catch (error) {
      emit(
        GroupChatRoomEntryState(
          status: GroupChatRoomEntryStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        const GroupChatRoomEntryState(
          status: GroupChatRoomEntryStatus.failure,
          errorMessage: '그룹 채팅방 정보를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.',
        ),
      );
    }
  }

  GroupChatRoomEntryState _resolveState(
    ChatRoom room, {
    String? actionErrorMessage,
  }) {
    if (!room.isPublic) {
      return GroupChatRoomEntryState(
        status: GroupChatRoomEntryStatus.restricted,
        room: room,
        errorMessage: actionErrorMessage,
      );
    }

    // Draft rooms are stored only locally and shouldn't be exposed remotely.
    final status = switch (room.status) {
      ChatRoomStatus.open => GroupChatRoomEntryStatus.preview,
      ChatRoomStatus.full => GroupChatRoomEntryStatus.full,
      ChatRoomStatus.closed => GroupChatRoomEntryStatus.closed,
      ChatRoomStatus.draft => GroupChatRoomEntryStatus.notFound,
    };

    return GroupChatRoomEntryState(
      status: status,
      room: room,
      errorMessage: actionErrorMessage,
    );
  }
}
