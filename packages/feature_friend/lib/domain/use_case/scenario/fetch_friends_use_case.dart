import 'package:feature_friend/domain/entity/friend.dart';
import 'package:feature_friend/domain/repository/friend_repository.dart';

final class FetchFriendsUseCase {
  FetchFriendsUseCase(this._friendRepository);

  final FriendRepository _friendRepository;

  Future<List<Friend>> call({int limit = 20, String? cursor}) {
    return _friendRepository.fetchFriends(limit: limit, cursor: cursor);
  }
}
