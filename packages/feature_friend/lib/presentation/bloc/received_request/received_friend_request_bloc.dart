import 'package:shared/shared.dart';
import 'package:feature_friend/domain/entity/friend_request.dart';
import 'package:feature_friend/domain/use_case/friend_use_cases.dart';
import 'package:injectable/injectable.dart';

@injectable
class ReceivedFriendRequestBloc
    extends CursorPaginationBloc<FriendRequest, String> {
  ReceivedFriendRequestBloc(this._friendUseCases) {
    init();
  }

  static const _pageSize = 20;

  final FriendUseCases _friendUseCases;

  @override
  String get fallbackErrorMessage => '받은 친구 요청을 불러오지 못했어요. 잠시 후 다시 시도해 주세요.';

  @override
  bool isSameItem(FriendRequest item, FriendRequest other) =>
      item.id == other.id;

  Future<void> acceptRequest(String requestId) async {
    await _friendUseCases.acceptFriendRequest(requestId);
    refresh();
  }

  Future<void> declineRequest(String requestId) async {
    await _friendUseCases.declineFriendRequest(requestId);
    refresh();
  }

  @override
  Future<CursorPaginationPage<FriendRequest, String>> fetchPage(
    String? cursor,
  ) async {
    final items = await _friendUseCases.fetchReceivedFriendRequests(
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
