import 'package:domodachi/features/friend/domain/entity/friend_request.dart';
import 'package:domodachi/features/friend/domain/repository/friend_repository.dart';

final class SendFriendRequestUseCase {
  SendFriendRequestUseCase(this._friendRepository);

  final FriendRepository _friendRepository;

  Future<FriendRequest> call({
    required String receiverUserId,
    String? message,
  }) {
    return _friendRepository.sendFriendRequest(
      receiverUserId: receiverUserId,
      message: message,
    );
  }
}
