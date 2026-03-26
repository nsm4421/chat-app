import 'package:domodachi/features/friend/domain/entity/friend_relationship.dart';
import 'package:domodachi/features/friend/domain/repository/friend_repository.dart';

final class FetchFriendRelationshipsUseCase {
  FetchFriendRelationshipsUseCase(this._friendRepository);

  final FriendRepository _friendRepository;

  Future<List<FriendRelationship>> call({required List<String> userIds}) {
    return _friendRepository.fetchFriendRelationships(userIds: userIds);
  }
}
