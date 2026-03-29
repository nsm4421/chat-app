import 'package:feature_chat_core/chat_core/data/model/chat_message_model.dart';
import 'package:feature_chat_core/chat_core/data/model/chat_message_overview_model.dart';
import 'package:feature_chat_core/chat_core/domain/entity/chat_message.dart';

extension ChatMessageModelMapper on ChatMessageModel {
  ChatMessage toChatMessage() {
    return ChatMessage(
      id: id,
      chatRoomId: chatRoomId,
      senderId: senderId,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      likeCount: 0,
      isLikedByMe: false,
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
      likeCount: likeCount,
      isLikedByMe: isLikedByMe,
    );
  }
}
