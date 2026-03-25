import 'package:domodachi/features/friend/domain/entity/friend_candidate.dart';
import 'package:domodachi/features/friend/domain/repository/friend_repository.dart';

final class SearchFriendProfilesUseCase {
  SearchFriendProfilesUseCase(this._friendRepository);

  final FriendRepository _friendRepository;

  Future<List<FriendCandidate>> call({required String query, int limit = 20}) {
    return _friendRepository.searchFriendProfiles(query: query, limit: limit);
  }
}
