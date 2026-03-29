import 'package:feature_friend/domain/entity/friend_request.dart';
import 'package:feature_friend/domain/repository/friend_repository.dart';

final class FetchReceivedFriendRequestsUseCase {
  FetchReceivedFriendRequestsUseCase(this._friendRepository);

  final FriendRepository _friendRepository;

  Future<List<FriendRequest>> call({int limit = 20, String? cursor}) {
    return _friendRepository.fetchReceivedFriendRequests(
      limit: limit,
      cursor: cursor,
    );
  }
}
