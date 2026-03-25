import 'package:domodachi/features/chat/data/model/chat_message_model.dart';
import 'package:domodachi/features/chat/data/model/chat_message_overview_model.dart';
import 'package:domodachi/features/chat/domain/entity/chat_message.dart';

extension ChatMessageModelMapper on ChatMessageModel {
  ChatMessage toChatMessage() {
    return ChatMessage(
      id: id,
      chatRoomId: chatRoomId,
      senderId: senderId,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension ChatMessageOverviewModelMapper on ChatMessageOverviewModel {
  ChatMessage toChatMessage() {
    return ChatMessage(
      id: id,
      chatRoomId: chatRoomId,
      senderId: senderId,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      anonymousIndex: anonymousIndex,
      senderDisplayName: senderDisplayName,
      senderUsername: senderUsername,
      senderAvatarUrl: senderAvatarUrl,
    );
  }
}
