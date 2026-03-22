import 'package:domodachi/features/chat/core/value_objects/chat_room_enums.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room.dart';
import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';
import 'package:domodachi/features/chat/domain/validation/chat_room_invariant_validator.dart';

final class CreateRemoteChatRoomUseCase {
  CreateRemoteChatRoomUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<ChatRoom> call({
    required ChatRoomStatus status,
    required ChatRoomType type,
    required int maxParticipants,
    required bool isPublic,
    String? title,
    String? description,
    List<String> tags = const <String>[],
  }) {
    ChatRoomInvariantValidator.validateOrThrow(
      type: type,
      maxParticipants: maxParticipants,
      isPublic: isPublic,
    );

    return _chatRepository.createRemoteChatRoom(
      status: status,
      type: type,
      maxParticipants: maxParticipants,
      isPublic: isPublic,
      title: title,
      description: description,
      tags: tags,
    );
  }
}
