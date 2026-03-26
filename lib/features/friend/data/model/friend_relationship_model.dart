final class FriendRelationshipModel {
  const FriendRelationshipModel({
    required this.userId,
    this.isFriend = false,
    this.sentRequestId,
    this.receivedRequestId,
  });

  final String userId;
  final bool isFriend;
  final String? sentRequestId;
  final String? receivedRequestId;
}
