import 'package:domodachi/features/chat/domain/entity/chat_message.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room_event.dart';
import 'package:domodachi/features/chat/presentation/bloc/room/chat_timeline_entry.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_list_state.freezed.dart';

enum ChatMessageListStatus {
  initial,
  loading,
  refreshing,
  loadingMore,
  success,
  failure,
}

@freezed
class ChatMessageListState with _$ChatMessageListState {
  const ChatMessageListState({
    required this.status,
    this.chatRoomId,
    this.items = const <ChatMessage>[],
    this.events = const <ChatRoomEvent>[],
    this.nextCursor,
    this.hasMore = true,
    this.errorMessage,
    this.roomDeleted = false,
  });

  factory ChatMessageListState.initial() {
    return const ChatMessageListState(status: ChatMessageListStatus.initial);
  }

  @override
  final ChatMessageListStatus status;

  @override
  final String? chatRoomId;

  @override
  final List<ChatMessage> items;

  @override
  final List<ChatRoomEvent> events;

  @override
  final String? nextCursor;

  @override
  final bool hasMore;

  @override
  final String? errorMessage;

  @override
  final bool roomDeleted;
}

extension ChatMessageListStateX on ChatMessageListState {
  bool get isInitial => status == ChatMessageListStatus.initial;

  bool get isLoading => status == ChatMessageListStatus.loading;

  bool get isRefreshing => status == ChatMessageListStatus.refreshing;

  bool get isLoadingMore => status == ChatMessageListStatus.loadingMore;

  bool get isSuccess => status == ChatMessageListStatus.success;

  bool get isFailure => status == ChatMessageListStatus.failure;

  bool get hasData => items.isNotEmpty || events.isNotEmpty;

  List<ChatTimelineEntry> get timelineItems {
    final timelineItems = <ChatTimelineEntry>[
      ...items.map(ChatTimelineEntry.message),
      ...events.map(ChatTimelineEntry.event),
    ];

    timelineItems.sort((a, b) {
      final compareCreatedAt = b.createdAt.compareTo(a.createdAt);
      if (compareCreatedAt != 0) {
        return compareCreatedAt;
      }

      return b.stableId.compareTo(a.stableId);
    });

    return timelineItems;
  }
}
