import 'package:shared/shared.dart';
import 'package:feature_chat_core/chat_core/domain/entity/chat_room.dart';
import 'package:feature_private_chat/private_chat/domain/use_case/private_chat_use_cases.dart';
import 'package:injectable/injectable.dart';

@injectable
class MyPrivateChatRoomBloc extends CursorPaginationBloc<ChatRoom, String> {
  MyPrivateChatRoomBloc(this._chatUseCases) {
    init();
  }

  final PrivateChatUseCases _chatUseCases;

  static const pageSize = 20;

  @override
  String get fallbackErrorMessage =>
      'private chat 목록을 불러오지 못했어요. 잠시 후 다시 시도해 주세요.';

  @override
  bool isSameItem(ChatRoom item, ChatRoom other) => item.id == other.id;

  @override
  Future<CursorPaginationPage<ChatRoom, String>> fetchPage(
    String? cursor,
  ) async {
    final rooms = await _chatUseCases.fetchMyPrivateChatRooms(
      limit: pageSize,
      cursor: cursor,
    );
    final items = rooms.toList(growable: false);
    final lastItem = items.isEmpty ? null : items.last;
    final nextCursor = (lastItem?.lastMessageAt ?? lastItem?.createdAt)
        ?.toIso8601String();

    return CursorPaginationPage<ChatRoom, String>(
      items: items,
      nextCursor: nextCursor,
      hasMore: items.length >= pageSize && nextCursor != null,
    );
  }
}
