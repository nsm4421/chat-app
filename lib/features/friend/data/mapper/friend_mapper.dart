import 'package:domodachi/features/friend/data/model/friend_candidate_model.dart';
import 'package:domodachi/features/friend/data/model/friend_model.dart';
import 'package:domodachi/features/friend/data/model/friend_profile_model.dart';
import 'package:domodachi/features/friend/data/model/friend_request_model.dart';
import 'package:domodachi/features/friend/domain/entity/friend.dart';
import 'package:domodachi/features/friend/domain/entity/friend_candidate.dart';
import 'package:domodachi/features/friend/domain/entity/friend_profile.dart';
import 'package:domodachi/features/friend/domain/entity/friend_request.dart';

extension FriendProfileModelMapper on FriendProfileModel {
  FriendProfile toFriendProfile() {
    return FriendProfile(
      id: id,
      displayName: displayName,
      username: username,
      avatarUrl: avatarUrl,
      bio: bio,
      lastSeenAt: lastSeenAt,
    );
  }
}

extension FriendModelMapper on FriendModel {
  Friend toFriend() {
    return Friend(profile: profile.toFriendProfile(), createdAt: createdAt);
  }
}

extension FriendCandidateModelMapper on FriendCandidateModel {
  FriendCandidate toFriendCandidate() {
    return FriendCandidate(
      profile: profile.toFriendProfile(),
      hasPendingRequest: hasPendingRequest,
      isFriend: isFriend,
    );
  }
}

extension FriendRequestModelMapper on FriendRequestModel {
  FriendRequest toFriendRequest() {
    return FriendRequest(
      id: id,
      requesterId: requesterId,
      receiverId: receiverId,
      status: status,
      message: message,
      respondedAt: respondedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      requester: requester.toFriendProfile(),
      receiver: receiver.toFriendProfile(),
    );
  }
}
