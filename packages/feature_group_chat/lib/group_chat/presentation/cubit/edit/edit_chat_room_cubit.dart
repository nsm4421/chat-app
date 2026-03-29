import 'package:shared/shared.dart';
import 'package:feature_chat_core/chat_core/core/value_objects/chat_room_enums.dart';
import 'package:feature_chat_core/chat_core/domain/entity/chat_room.dart';
import 'package:feature_group_chat/group_chat/domain/use_case/group_chat_use_cases.dart';
import 'package:feature_group_chat/group_chat/presentation/cubit/edit/chat_room_form_cubit.dart';
import 'package:feature_group_chat/group_chat/presentation/cubit/edit/chat_room_form_state.dart';
import 'package:feature_group_chat/group_chat/presentation/cubit/edit/edit_chat_room_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditChatRoomCubit extends Cubit<EditChatRoomState> {
  EditChatRoomCubit(this._chatUseCases, this._formCubit)
    : super(const EditChatRoomState.idle());

  final GroupChatUseCases _chatUseCases;
  final ChatRoomFormCubit _formCubit;

  ChatRoom? _editingRoom;

  Future<void> initializeForCreate() async {
    emit(const EditChatRoomState.idle());

    try {
      final draft = await _chatUseCases.getDraftChatRoom();
      if (draft != null) {
        emit(EditChatRoomState.draftFound(draft));
        return;
      }
    } on Failure catch (error) {
      emit(EditChatRoomState.error(error.message));
    }

    _editingRoom = null;
    _formCubit.initializeForCreateGroup();
    emit(const EditChatRoomState.initial());
  }

  void initializeForUpdate(ChatRoom room) {
    _editingRoom = room;
    _formCubit.initializeForUpdate(room);
    emit(const EditChatRoomState.initial());
  }

  void restoreDraft(ChatRoom draft) {
    _editingRoom = null;
    _formCubit.restoreCreateGroupDraft(draft);
    emit(const EditChatRoomState.initial());
  }

  Future<void> discardDraft() async {
    try {
      await _chatUseCases.deleteDraftChatRoom();
    } on Failure catch (error) {
      emit(EditChatRoomState.error(error.message));
    }

    _editingRoom = null;
    _formCubit.initializeForCreateGroup();
    emit(const EditChatRoomState.initial());
  }

  Future<void> save() async {
    if (!_formCubit.validate()) {
      emit(const EditChatRoomState.error('입력값을 확인해 주세요.'));
      return;
    }

    emit(const EditChatRoomState.loading());

    try {
      if (_editingRoom == null) {
        if (_formCubit.state.status == ChatRoomStatus.draft) {
          await _chatUseCases.saveDraftChatRoom(
            type: ChatRoomType.group,
            maxParticipants: _formCubit.state.maxParticipants,
            isPublic: _formCubit.state.isPublic,
            title: _formCubit.state.normalizedTitle,
            description: _formCubit.state.normalizedDescription,
            tags: _formCubit.state.normalizedTags,
          );
        } else {
          await _chatUseCases.createRemoteChatRoom(
            status: _formCubit.state.status,
            type: ChatRoomType.group,
            maxParticipants: _formCubit.state.maxParticipants,
            isPublic: _formCubit.state.isPublic,
            title: _formCubit.state.normalizedTitle,
            description: _formCubit.state.normalizedDescription,
            tags: _formCubit.state.normalizedTags,
          );
        }
        emit(const EditChatRoomState.success('채팅방을 저장했어요.'));
        return;
      }

      await _chatUseCases.updateChatRoom(
        chatRoomId: _editingRoom!.id,
        title: _formCubit.state.normalizedTitle,
        description: _formCubit.state.normalizedDescription,
        tags: _formCubit.state.normalizedTags,
        maxParticipants: _formCubit.state.maxParticipants,
        status: _formCubit.state.status,
        isPublic: _formCubit.state.isPublic,
      );
      emit(const EditChatRoomState.success('채팅방을 수정했어요.'));
    } on Failure catch (error) {
      emit(EditChatRoomState.error(error.message));
    }
  }

  Future<void> saveDraftOnExit() async {
    if (state.isLoading || state.isCompleted) {
      return;
    }

    final formState = _formCubit.state;
    if (!formState.hasDraftContent) {
      return;
    }

    try {
      await _chatUseCases.saveDraftChatRoom(
        type: ChatRoomType.group,
        maxParticipants: formState.maxParticipants,
        isPublic: formState.isPublic,
        title: formState.normalizedTitle,
        description: formState.normalizedDescription,
        tags: formState.normalizedTags,
      );
    } on Failure {
      // Draft persistence on exit is best-effort.
    }
  }
}
