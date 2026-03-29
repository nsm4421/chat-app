import 'package:feature_friend/domain/repository/friend_repository.dart';

final class CancelFriendRequestUseCase {
  CancelFriendRequestUseCase(this._friendRepository);

  final FriendRepository _friendRepository;

  Future<void> call(String requestId) {
    return _friendRepository.cancelFriendRequest(requestId);
  }
}
