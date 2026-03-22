import 'package:domodachi/features/chat/core/value_objects/chat_room_enums.dart';
import 'package:domodachi/features/chat/data/model/chat_room_draft_model.dart';
import 'package:domodachi/features/chat/data/model/chat_room_model.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room.dart';

extension ChatRoomModelMapper on ChatRoomModel {
  ChatRoom toChatRoom() {
    return ChatRoom(
      id: id,
      createdBy: createdBy,
      type: type,
      title: title,
      description: description,
      tags: tags,
      maxParticipants: maxParticipants,
      status: status,
      isPublic: isPublic,
      lastMessageAt: lastMessageAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      memberCount: memberCount,
      isJoined: isJoined,
      isHost: isHost,
    );
  }
}

extension ChatRoomDraftModelMapper on ChatRoomDraftModel {
  ChatRoom toChatRoom() {
    return ChatRoom(
      id: 'local-draft',
      createdBy: 'local',
      type: type,
      title: title,
      description: description,
      tags: tags,
      maxParticipants: maxParticipants,
      status: ChatRoomStatus.draft,
      isPublic: isPublic,
      createdAt: savedAt,
      updatedAt: savedAt,
      isJoined: true,
      isHost: true,
    );
  }
}
