import 'package:shared/shared.dart';
import 'package:feature_friend/domain/entity/friend.dart';
import 'package:feature_friend/domain/use_case/friend_use_cases.dart';
import 'package:injectable/injectable.dart';

@injectable
class FriendListBloc extends CursorPaginationBloc<Friend, String> {
  FriendListBloc(this._friendUseCases) {
    init();
  }

  static const _pageSize = 20;

  final FriendUseCases _friendUseCases;

  @override
  String get fallbackErrorMessage => '친구 목록을 불러오지 못했어요. 잠시 후 다시 시도해 주세요.';

  @override
  bool isSameItem(Friend item, Friend other) =>
      item.profile.id == other.profile.id;

  Future<void> removeFriend(String friendUserId) async {
    await _friendUseCases.removeFriend(friendUserId);
    refresh();
  }

  @override
  Future<CursorPaginationPage<Friend, String>> fetchPage(String? cursor) async {
    final items = await _friendUseCases.fetchFriends(
      limit: _pageSize,
      cursor: cursor,
    );
    final lastItem = items.isEmpty ? null : items.last;
    final nextCursor = lastItem?.createdAt.toIso8601String();

    return CursorPaginationPage<Friend, String>(
      items: items,
      nextCursor: nextCursor,
      hasMore: items.length >= _pageSize && nextCursor != null,
    );
  }
}
