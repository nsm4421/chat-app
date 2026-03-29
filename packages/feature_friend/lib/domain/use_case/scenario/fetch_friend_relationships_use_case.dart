import 'package:feature_friend/domain/entity/friend_relationship.dart';
import 'package:feature_friend/domain/repository/friend_repository.dart';

final class FetchFriendRelationshipsUseCase {
  FetchFriendRelationshipsUseCase(this._friendRepository);

  final FriendRepository _friendRepository;

  Future<List<FriendRelationship>> call({required List<String> userIds}) {
    return _friendRepository.fetchFriendRelationships(userIds: userIds);
  }
}
