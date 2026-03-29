import 'dart:async';

import 'package:shared/shared.dart';
import 'package:feature_chat_core/chat_core/domain/entity/chat_room_member.dart';
import 'package:feature_chat_core/chat_core/domain/entity/chat_room_presence.dart';
import 'package:feature_group_chat/group_chat/domain/use_case/group_chat_use_cases.dart';
import 'package:feature_group_chat/group_chat/presentation/cubit/room/chat_room_session_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class ChatRoomSessionCubit extends Cubit<ChatRoomSessionState> {
  ChatRoomSessionCubit(this._chatUseCases, @factoryParam String chatRoomId)
    : _chatRoomId = chatRoomId,
      super(ChatRoomSessionState.initial()) {
    unawaited(load());
  }

  final GroupChatUseCases _chatUseCases;

  StreamSubscription<List<ChatRoomMember>>? _memberSubscription;
  StreamSubscription<List<ChatRoomPresence>>? _presenceSubscription;
  StreamSubscription<ChatRoomPresenceEvent>? _presenceEventSubscription;

  final String _chatRoomId;
  bool _presenceEntered = false;

  Future<void> load() async {
    await _cancelSubscriptions();

    emit(
      ChatRoomSessionState(
        status: ChatRoomSessionStatus.loading,
        chatRoomId: _chatRoomId,
      ),
    );

    await _loadSnapshot(_chatRoomId);
  }

  Future<void> retry() async {
    await load();
  }

  Future<void> join() async {
    final room = state.room;
    if (room == null || !state.canJoin) {
      return;
    }

    emit(state.copyWith(isJoining: true, errorMessage: null));

    try {
      await _chatUseCases.joinGroupChatRoom(_chatRoomId);
      _presenceEntered = true;
      _bindPresenceStreams(_chatRoomId);
      await _loadSnapshot(
        _chatRoomId,
        forceIsMember: true,
        preservePresenceState: true,
      );
    } on Failure catch (error) {
      emit(state.copyWith(isJoining: false, errorMessage: error.message));
    } catch (_) {
      emit(
        state.copyWith(
          isJoining: false,
          errorMessage: '채팅방에 참여하지 못했어요. 잠시 후 다시 시도해 주세요.',
        ),
      );
    }
  }

  Future<bool> leave() async {
    if (!state.canLeave) {
      return false;
    }

    emit(state.copyWith(isLeaving: true, errorMessage: null));

    try {
      await _chatUseCases.leaveGroupChatRoom(_chatRoomId);
      _presenceEntered = false;
      await _cancelPresenceSubscriptions();
      await _loadSnapshot(
        _chatRoomId,
        forceIsMember: false,
        preservePresenceState: false,
      );
      return true;
    } on Failure catch (error) {
      emit(state.copyWith(isLeaving: false, errorMessage: error.message));
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          isLeaving: false,
          errorMessage: '채팅방에서 나가지 못했어요. 잠시 후 다시 시도해 주세요.',
        ),
      );
      return false;
    }
  }

  Future<bool> deleteRoom() async {
    if (!state.canDeleteRoom) {
      return false;
    }

    emit(state.copyWith(isLeaving: true, errorMessage: null));

    try {
      await _chatUseCases.deleteChatRoom(_chatRoomId);
      await _clearRoomBindings(chatRoomId: _chatRoomId, leavePresence: true);
      return true;
    } on Failure catch (error) {
      emit(state.copyWith(isLeaving: false, errorMessage: error.message));
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          isLeaving: false,
          errorMessage: '채팅방을 삭제하지 못했어요. 잠시 후 다시 시도해 주세요.',
        ),
      );
      return false;
    }
  }

  Future<void> _loadSnapshot(
    String chatRoomId, {
    bool? forceIsMember,
    bool preservePresenceState = false,
  }) async {
    try {
      final room = await _chatUseCases.getChatRoom(chatRoomId);
      if (room == null) {
        emit(
          ChatRoomSessionState(
            status: ChatRoomSessionStatus.notFound,
            chatRoomId: chatRoomId,
            errorMessage: '채팅방을 찾을 수 없어요.',
          ),
        );
        return;
      }

      final members = await _chatUseCases.fetchChatRoomMembers(
        chatRoomId: chatRoomId,
      );
      final isMember = forceIsMember ?? room.isJoined;

      emit(
        ChatRoomSessionState(
          status: ChatRoomSessionStatus.ready,
          chatRoomId: chatRoomId,
          room: room,
          members: members,
          presences: preservePresenceState ? state.presences : const [],
          lastPresenceEvent: preservePresenceState
              ? state.lastPresenceEvent
              : null,
          isMember: isMember,
        ),
      );

      _bindMemberStream(chatRoomId);

      if (isMember) {
        if (!_presenceEntered) {
          await _chatUseCases.enterChatRoomPresence(chatRoomId);
          _presenceEntered = true;
        }
        _bindPresenceStreams(chatRoomId);
      } else {
        await _cancelPresenceSubscriptions();
      }
    } on Failure catch (error) {
      emit(
        ChatRoomSessionState(
          status: ChatRoomSessionStatus.failure,
          chatRoomId: chatRoomId,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        ChatRoomSessionState(
          status: ChatRoomSessionStatus.failure,
          chatRoomId: chatRoomId,
          errorMessage: '채팅방 정보를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.',
        ),
      );
    }
  }

  void _bindMemberStream(String chatRoomId) {
    _memberSubscription?.cancel();
    _memberSubscription = _chatUseCases
        .watchChatRoomMembers(chatRoomId: chatRoomId)
        .listen(
          (members) {
            emit(state.copyWith(members: members));
          },
          onError: (Object error) {
            if (error is Failure) {
              emit(state.copyWith(errorMessage: error.message));
            }
          },
        );
  }

  void _bindPresenceStreams(String chatRoomId) {
    _presenceSubscription?.cancel();
    _presenceEventSubscription?.cancel();

    _presenceSubscription = _chatUseCases
        .watchChatRoomPresence(chatRoomId: chatRoomId)
        .listen(
          (presences) {
            emit(state.copyWith(presences: presences));
          },
          onError: (Object error) {
            if (error is Failure) {
              emit(state.copyWith(errorMessage: error.message));
            }
          },
        );

    _presenceEventSubscription = _chatUseCases
        .watchChatRoomPresenceEvents(chatRoomId: chatRoomId)
        .listen(
          (event) {
            emit(state.copyWith(lastPresenceEvent: event));
          },
          onError: (Object error) {
            if (error is Failure) {
              emit(state.copyWith(errorMessage: error.message));
            }
          },
        );
  }

  Future<void> _clearRoomBindings({
    required String? chatRoomId,
    required bool leavePresence,
  }) async {
    await _cancelSubscriptions();

    if (leavePresence && _presenceEntered && chatRoomId != null) {
      try {
        await _chatUseCases.leaveChatRoomPresence(chatRoomId);
      } catch (_) {
        // Ignore cleanup failures during room switches.
      }
    }

    _presenceEntered = false;
  }

  Future<void> _cancelSubscriptions() async {
    await _memberSubscription?.cancel();
    _memberSubscription = null;
    await _cancelPresenceSubscriptions();
  }

  Future<void> _cancelPresenceSubscriptions() async {
    await _presenceSubscription?.cancel();
    await _presenceEventSubscription?.cancel();
    _presenceSubscription = null;
    _presenceEventSubscription = null;
  }

  @override
  Future<void> close() async {
    await _clearRoomBindings(chatRoomId: _chatRoomId, leavePresence: true);
    return super.close();
  }
}
