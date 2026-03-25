import 'package:domodachi/features/friend/data/data_source/friend_data_source.dart';
import 'package:domodachi/features/friend/data/mapper/friend_mapper.dart';
import 'package:domodachi/features/friend/data/repository/friend_repository_error_handler.dart';
import 'package:domodachi/features/friend/domain/entity/friend.dart';
import 'package:domodachi/features/friend/domain/entity/friend_candidate.dart';
import 'package:domodachi/features/friend/domain/entity/friend_request.dart';
import 'package:domodachi/features/friend/domain/repository/friend_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: FriendRepository)
class FriendRepositoryImpl
    with FriendRepositoryErrorHandler
    implements FriendRepository {
  FriendRepositoryImpl(this._friendDataSource);

  final FriendDataSource _friendDataSource;

  @override
  Future<List<Friend>> fetchFriends({int limit = 20, String? cursor}) async {
    return guardFriendRequest(() async {
      final items = await _friendDataSource.fetchFriends(
        limit: limit,
        cursor: cursor,
      );
      return items.map((item) => item.toFriend()).toList(growable: false);
    }, fallbackMessage: '친구 목록을 불러오지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  @override
  Future<List<FriendRequest>> fetchReceivedFriendRequests({
    int limit = 20,
    String? cursor,
  }) async {
    return guardFriendRequest(() async {
      final items = await _friendDataSource.fetchReceivedFriendRequests(
        limit: limit,
        cursor: cursor,
      );
      return items
          .map((item) => item.toFriendRequest())
          .toList(growable: false);
    }, fallbackMessage: '받은 친구 요청을 불러오지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  @override
  Future<List<FriendRequest>> fetchSentFriendRequests({
    int limit = 20,
    String? cursor,
  }) async {
    return guardFriendRequest(() async {
      final items = await _friendDataSource.fetchSentFriendRequests(
        limit: limit,
        cursor: cursor,
      );
      return items
          .map((item) => item.toFriendRequest())
          .toList(growable: false);
    }, fallbackMessage: '보낸 친구 요청을 불러오지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  @override
  Future<List<FriendCandidate>> searchFriendProfiles({
    required String query,
    int limit = 20,
  }) async {
    return guardFriendRequest(() async {
      final items = await _friendDataSource.searchFriendProfiles(
        query: query,
        limit: limit,
      );
      return items
          .map((item) => item.toFriendCandidate())
          .toList(growable: false);
    }, fallbackMessage: '친구 검색을 처리하지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  @override
  Future<FriendRequest> sendFriendRequest({
    required String receiverUserId,
    String? message,
  }) async {
    return guardFriendRequest(() async {
      final request = await _friendDataSource.sendFriendRequest(
        receiverUserId: receiverUserId,
        message: message,
      );
      return request.toFriendRequest();
    }, fallbackMessage: '친구 요청을 보내지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  @override
  Future<void> acceptFriendRequest(String requestId) async {
    await guardFriendRequest(
      () => _friendDataSource.acceptFriendRequest(requestId),
      fallbackMessage: '친구 요청을 수락하지 못했어요. 잠시 후 다시 시도해 주세요.',
    );
  }

  @override
  Future<void> declineFriendRequest(String requestId) async {
    await guardFriendRequest(
      () => _friendDataSource.declineFriendRequest(requestId),
      fallbackMessage: '친구 요청을 거절하지 못했어요. 잠시 후 다시 시도해 주세요.',
    );
  }

  @override
  Future<void> cancelFriendRequest(String requestId) async {
    await guardFriendRequest(
      () => _friendDataSource.cancelFriendRequest(requestId),
      fallbackMessage: '친구 요청을 취소하지 못했어요. 잠시 후 다시 시도해 주세요.',
    );
  }

  @override
  Future<void> removeFriend(String friendUserId) async {
    await guardFriendRequest(
      () => _friendDataSource.removeFriend(friendUserId),
      fallbackMessage: '친구를 삭제하지 못했어요. 잠시 후 다시 시도해 주세요.',
    );
  }
}
