import 'dart:async';

import 'package:shared/shared.dart';
import 'package:feature_chat_core/chat_core/domain/entity/chat_room_event.dart';
import 'package:feature_chat_core/chat_core/domain/entity/chat_room.dart';
import 'package:feature_group_chat/group_chat/domain/use_case/group_chat_use_cases.dart';
import 'package:injectable/injectable.dart';

@injectable
class GroupChatRoomBloc extends CursorPaginationBloc<ChatRoom, String> {
  GroupChatRoomBloc(this._chatUseCases) {
    _deletedRoomSubscription = _chatUseCases
        .watchDeletedChatRoomEvents()
        .listen(_handleDeletedRoomEvent);
    init();
  }

  static const _pageSize = 20;

  final GroupChatUseCases _chatUseCases;
  StreamSubscription<ChatRoomEvent>? _deletedRoomSubscription;

  @override
  String get fallbackErrorMessage => '그룹채팅 목록을 불러오지 못했어요. 잠시 후 다시 시도해 주세요.';

  @override
  bool isSameItem(ChatRoom item, ChatRoom other) => item.id == other.id;

  void _handleDeletedRoomEvent(ChatRoomEvent event) {
    if (event.type != ChatRoomEventType.roomDeleted) {
      return;
    }

    final roomId = event.chatRoomId;
    for (final room in state.items) {
      if (room.id == roomId) {
        itemDeleted(room);
        return;
      }
    }
  }

  @override
  Future<CursorPaginationPage<ChatRoom, String>> fetchPage(
    String? cursor,
  ) async {
    final items = (await _chatUseCases.fetchDiscoverChatRooms(
      limit: _pageSize,
      cursor: cursor,
    )).toList(growable: false);

    final lastItem = items.isEmpty ? null : items.last;
    final nextCursor = (lastItem?.lastMessageAt ?? lastItem?.createdAt)
        ?.toIso8601String();

    return CursorPaginationPage<ChatRoom, String>(
      items: items,
      nextCursor: nextCursor,
      hasMore: items.length >= _pageSize && nextCursor != null,
    );
  }

  @override
  Future<void> close() async {
    await _deletedRoomSubscription?.cancel();
    return super.close();
  }
}
