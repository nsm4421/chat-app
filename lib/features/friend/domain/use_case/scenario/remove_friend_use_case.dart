import 'package:domodachi/features/friend/domain/repository/friend_repository.dart';

final class RemoveFriendUseCase {
  RemoveFriendUseCase(this._friendRepository);

  final FriendRepository _friendRepository;

  Future<void> call(String friendUserId) {
    return _friendRepository.removeFriend(friendUserId);
  }
}
