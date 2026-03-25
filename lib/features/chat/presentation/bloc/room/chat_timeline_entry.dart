import 'package:domodachi/features/chat/domain/entity/chat_message.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room_event.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_timeline_entry.freezed.dart';

@freezed
sealed class ChatTimelineEntry with _$ChatTimelineEntry {
  const factory ChatTimelineEntry.message(ChatMessage message) =
      ChatTimelineEntryMessage;

  const factory ChatTimelineEntry.event(ChatRoomEvent event) =
      ChatTimelineEntryEvent;
}

extension ChatTimelineEntryX on ChatTimelineEntry {
  DateTime get createdAt => switch (this) {
    ChatTimelineEntryMessage(:final message) => message.createdAt,
    ChatTimelineEntryEvent(:final event) => event.createdAt,
  };

  String get stableId => switch (this) {
    ChatTimelineEntryMessage(:final message) => 'message:${message.id}',
    ChatTimelineEntryEvent(:final event) => 'event:${event.id}',
  };
}
