import 'package:domodachi/features/chat/core/value_objects/chat_room_enums.dart';
import 'package:domodachi/features/chat/domain/failure/chat_failure.dart';
import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';
import 'package:domodachi/features/chat/domain/validation/chat_room_invariant_validator.dart';

final class UpdateChatRoomUseCase {
  UpdateChatRoomUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<void> call({
    required String chatRoomId,
    String? title,
    String? description,
    List<String>? tags,
    int? maxParticipants,
    ChatRoomStatus? status,
    bool? isPublic,
  }) async {
    // Updates do not carry room type, so we rehydrate the current room first
    // and validate the final private/group invariants before persisting.
    final room = await _chatRepository.getChatRoom(chatRoomId);
    if (room == null) {
      throw const ChatFailure('채팅방을 찾을 수 없어요.');
    }

    ChatRoomInvariantValidator.validateOrThrow(
      type: room.type,
      maxParticipants: maxParticipants ?? room.maxParticipants,
      isPublic: isPublic ?? room.isPublic,
    );

    return _chatRepository.updateChatRoom(
      chatRoomId: chatRoomId,
      title: title,
      description: description,
      tags: tags,
      maxParticipants: maxParticipants,
      status: status,
      isPublic: isPublic,
    );
  }
}
