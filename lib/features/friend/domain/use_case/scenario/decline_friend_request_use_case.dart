import 'package:domodachi/features/friend/domain/repository/friend_repository.dart';

final class DeclineFriendRequestUseCase {
  DeclineFriendRequestUseCase(this._friendRepository);

  final FriendRepository _friendRepository;

  Future<void> call(String requestId) {
    return _friendRepository.declineFriendRequest(requestId);
  }
}
