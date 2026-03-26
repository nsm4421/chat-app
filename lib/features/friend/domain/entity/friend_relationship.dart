final class FriendRelationship {
  const FriendRelationship({
    required this.userId,
    this.isFriend = false,
    this.sentRequestId,
    this.receivedRequestId,
  });

  final String userId;
  final bool isFriend;
  final String? sentRequestId;
  final String? receivedRequestId;

  bool get hasSentPendingRequest => sentRequestId != null;
  bool get hasReceivedPendingRequest => receivedRequestId != null;
}
