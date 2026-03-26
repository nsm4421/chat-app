import 'package:domodachi/features/friend/data/model/friend_relationship_model.dart'
    as data;
import 'package:domodachi/features/friend/domain/entity/friend_relationship.dart'
    as domain;

extension FriendRelationshipModelMapper on data.FriendRelationshipModel {
  domain.FriendRelationship toFriendRelationship() {
    return domain.FriendRelationship(
      userId: userId,
      isFriend: isFriend,
      sentRequestId: sentRequestId,
      receivedRequestId: receivedRequestId,
    );
  }
}
