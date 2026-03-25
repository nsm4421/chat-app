import 'package:domodachi/core/pagination/cursor_pagination_bloc.dart';
import 'package:domodachi/core/pagination/cursor_pagination_page.dart';
import 'package:domodachi/features/friend/domain/entity/friend_request.dart';
import 'package:domodachi/features/friend/domain/use_case/friend_use_cases.dart';
import 'package:injectable/injectable.dart';

@injectable
class SentFriendRequestBloc
    extends CursorPaginationBloc<FriendRequest, String> {
  SentFriendRequestBloc(this._friendUseCases) {
    init();
  }

  static const _pageSize = 20;

  final FriendUseCases _friendUseCases;

  @override
  String get fallbackErrorMessage => '보낸 친구 요청을 불러오지 못했어요. 잠시 후 다시 시도해 주세요.';

  @override
  bool isSameItem(FriendRequest item, FriendRequest other) =>
      item.id == other.id;

  Future<void> cancelRequest(String requestId) async {
    await _friendUseCases.cancelFriendRequest(requestId);
    refresh();
  }

  @override
  Future<CursorPaginationPage<FriendRequest, String>> fetchPage(
    String? cursor,
  ) async {
    final items = await _friendUseCases.fetchSentFriendRequests(
      limit: _pageSize,
      cursor: cursor,
    );
    final lastItem = items.isEmpty ? null : items.last;
    final nextCursor = lastItem?.createdAt.toIso8601String();

    return CursorPaginationPage<FriendRequest, String>(
      items: items,
      nextCursor: nextCursor,
      hasMore: items.length >= _pageSize && nextCursor != null,
    );
  }
}
