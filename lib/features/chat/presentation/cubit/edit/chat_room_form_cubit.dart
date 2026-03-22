import 'package:domodachi/features/chat/core/value_objects/chat_room_enums.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room.dart';
import 'package:domodachi/features/chat/domain/validation/chat_room_field_rules.dart';
import 'package:domodachi/features/chat/domain/validation/chat_room_input_validator.dart';
import 'package:domodachi/features/chat/presentation/cubit/edit/chat_room_form_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class ChatRoomFormCubit extends Cubit<ChatRoomFormState> {
  ChatRoomFormCubit() : super(ChatRoomFormState.create());

  void initializeForCreate() {
    emit(ChatRoomFormState.create());
  }

  void initializeForCreateGroup() {
    emit(ChatRoomFormState.create());
  }

  void initializeForUpdate(ChatRoom room) {
    emit(_validate(ChatRoomFormState.fromChatRoom(room)));
  }

  void restoreCreateGroupDraft(ChatRoom room) {
    emit(
      _validate(
        ChatRoomFormState.fromChatRoom(room).copyWith(
          type: ChatRoomType.group,
          maxParticipants: room.maxParticipants.clamp(
            ChatRoomFieldRules.groupMinParticipants,
            ChatRoomFieldRules.groupMaxParticipants,
          ),
        ),
      ),
    );
  }

  void typeChanged(ChatRoomType type) {
    emit(
      _validate(
        state.copyWith(
          type: type,
          isPublic: type == ChatRoomType.group,
          maxParticipants: type == ChatRoomType.private
              ? ChatRoomFieldRules.privateParticipantCount
              : state.maxParticipants.clamp(
                  ChatRoomFieldRules.groupMinParticipants,
                  ChatRoomFieldRules.groupMaxParticipants,
                ),
        ),
      ),
    );
  }

  void statusChanged(ChatRoomStatus status) {
    emit(state.copyWith(status: status));
  }

  void titleChanged(String value) {
    emit(_validate(state.copyWith(title: value)));
  }

  void descriptionChanged(String value) {
    emit(_validate(state.copyWith(description: value)));
  }

  void tagsChanged(List<String> values) {
    emit(_validate(state.copyWith(tags: values)));
  }

  void maxParticipantsChanged(int value) {
    emit(_validate(state.copyWith(maxParticipants: value)));
  }

  bool validate() {
    final nextState = _validate(state);
    emit(nextState);
    return nextState.isValid;
  }

  ChatRoomFormState _validate(ChatRoomFormState current) {
    return current.copyWith(
      titleError: ChatRoomInputValidator.title(
        current.title,
        isPrivate: current.isPrivate,
      ),
      descriptionError: ChatRoomInputValidator.description(
        current.description,
        isPrivate: current.isPrivate,
      ),
      tagsError: ChatRoomInputValidator.tags(current.tags),
      maxParticipantsError: ChatRoomInputValidator.maxParticipants(
        current.maxParticipants,
        isPrivate: current.isPrivate,
      ),
    );
  }
}
