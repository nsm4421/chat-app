import 'package:domodachi/features/friend/domain/repository/friend_repository.dart';

final class AcceptFriendRequestUseCase {
  AcceptFriendRequestUseCase(this._friendRepository);

  final FriendRepository _friendRepository;

  Future<void> call(String requestId) {
    return _friendRepository.acceptFriendRequest(requestId);
  }
}
