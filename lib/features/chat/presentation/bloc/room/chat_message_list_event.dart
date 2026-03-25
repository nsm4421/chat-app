import 'package:domodachi/features/chat/domain/entity/chat_message.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room_event.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_list_event.freezed.dart';

@freezed
sealed class ChatMessageListEvent with _$ChatMessageListEvent {
  const factory ChatMessageListEvent.initialize(String chatRoomId) =
      ChatMessageListInitialized;

  const factory ChatMessageListEvent.refreshRequested() =
      ChatMessageListRefreshRequested;

  const factory ChatMessageListEvent.fetchMoreRequested() =
      ChatMessageListFetchMoreRequested;

  const factory ChatMessageListEvent.messageReceived(ChatMessage message) =
      ChatMessageListMessageReceived;

  const factory ChatMessageListEvent.roomEventReceived(ChatRoomEvent event) =
      ChatMessageListRoomEventReceived;

  const factory ChatMessageListEvent.messageDeleted(String chatMessageId) =
      ChatMessageListMessageDeleted;

  const factory ChatMessageListEvent.subscriptionFailed(String message) =
      ChatMessageListSubscriptionFailed;
}
