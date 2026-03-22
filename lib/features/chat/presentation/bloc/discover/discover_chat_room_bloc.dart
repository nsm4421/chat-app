import 'package:domodachi/core/pagination/cursor_pagination_bloc.dart';
import 'package:domodachi/core/pagination/cursor_pagination_page.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room.dart';
import 'package:domodachi/features/chat/domain/use_case/chat_use_cases.dart';
import 'package:injectable/injectable.dart';

@injectable
class DiscoverChatRoomBloc extends CursorPaginationBloc<ChatRoom, String> {
  DiscoverChatRoomBloc(this._chatUseCases) {
    init();
  }

  static const _pageSize = 20;

  final ChatUseCases _chatUseCases;

  @override
  String get fallbackErrorMessage => '탐색할 채팅방을 불러오지 못했어요. 잠시 후 다시 시도해 주세요.';

  @override
  bool isSameItem(ChatRoom item, ChatRoom other) => item.id == other.id;

  @override
  Future<CursorPaginationPage<ChatRoom, String>> fetchPage(
    String? cursor,
  ) async {
    final rooms = await _chatUseCases.fetchDiscoverChatRooms(
      limit: _pageSize,
      cursor: cursor,
    );

    final items = rooms.toList(growable: false);
    final lastItem = items.isEmpty ? null : items.last;
    final nextCursor = (lastItem?.lastMessageAt ?? lastItem?.createdAt)
        ?.toIso8601String();

    return CursorPaginationPage<ChatRoom, String>(
      items: items,
      nextCursor: nextCursor,
      hasMore: items.length >= _pageSize && nextCursor != null,
    );
  }
}
