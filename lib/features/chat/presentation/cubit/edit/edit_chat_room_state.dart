import 'package:domodachi/features/chat/domain/entity/chat_room.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_chat_room_state.freezed.dart';

@freezed
sealed class EditChatRoomState with _$EditChatRoomState {
  const factory EditChatRoomState.idle() = _Idle;

  const factory EditChatRoomState.draftFound(ChatRoom draft) = _DraftFound;

  const factory EditChatRoomState.initial() = _Initial;

  const factory EditChatRoomState.loading() = _Loading;

  const factory EditChatRoomState.success([String? message]) = _Success;

  const factory EditChatRoomState.error(String message) = _Error;
}

extension EditChatRoomStateX on EditChatRoomState {
  bool get isLoading => maybeWhen(loading: () => true, orElse: () => false);

  bool get isCompleted => maybeWhen(success: (_) => true, orElse: () => false);
}
