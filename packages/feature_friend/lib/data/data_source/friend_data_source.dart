import 'package:feature_friend/data/model/friend_candidate_model.dart';
import 'package:feature_friend/data/model/friend_model.dart';
import 'package:feature_friend/data/model/friend_relationship_model.dart';
import 'package:feature_friend/data/model/friend_request_model.dart';

abstract interface class FriendDataSource {
  Future<Iterable<FriendModel>> fetchFriends({int limit = 20, String? cursor});

  Future<Iterable<FriendRequestModel>> fetchReceivedFriendRequests({
    int limit = 20,
    String? cursor,
  });

  Future<Iterable<FriendRequestModel>> fetchSentFriendRequests({
    int limit = 20,
    String? cursor,
  });

  Future<Iterable<FriendRelationshipModel>> fetchFriendRelationships({
    required List<String> userIds,
  });

  Future<Iterable<FriendCandidateModel>> searchFriendProfiles({
    required String query,
    int limit = 20,
  });

  Future<FriendRequestModel> sendFriendRequest({
    required String receiverUserId,
    String? message,
  });

  Future<void> acceptFriendRequest(String requestId);

  Future<void> declineFriendRequest(String requestId);

  Future<void> cancelFriendRequest(String requestId);

  Future<void> removeFriend(String friendUserId);
}
