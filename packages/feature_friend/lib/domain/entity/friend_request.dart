import 'package:feature_friend/core/value_objects/friend_request_status.dart';
import 'package:feature_friend/domain/entity/friend_profile.dart';

final class FriendRequest {
  const FriendRequest({
    required this.id,
    required this.requesterId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.requester,
    required this.receiver,
    this.message,
    this.respondedAt,
  });

  final String id;
  final String requesterId;
  final String receiverId;
  final FriendRequestStatus status;
  final String? message;
  final DateTime? respondedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final FriendProfile requester;
  final FriendProfile receiver;

  bool get isPending => status == FriendRequestStatus.pending;
}
