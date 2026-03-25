import 'package:domodachi/features/friend/domain/entity/friend.dart';
import 'package:domodachi/features/friend/domain/entity/friend_candidate.dart';
import 'package:domodachi/features/friend/domain/entity/friend_request.dart';

abstract class FriendRepository {
  Future<List<Friend>> fetchFriends({int limit = 20, String? cursor});

  Future<List<FriendRequest>> fetchReceivedFriendRequests({
    int limit = 20,
    String? cursor,
  });

  Future<List<FriendRequest>> fetchSentFriendRequests({
    int limit = 20,
    String? cursor,
  });

  Future<List<FriendCandidate>> searchFriendProfiles({
    required String query,
    int limit = 20,
  });

  Future<FriendRequest> sendFriendRequest({
    required String receiverUserId,
    String? message,
  });

  Future<void> acceptFriendRequest(String requestId);

  Future<void> declineFriendRequest(String requestId);

  Future<void> cancelFriendRequest(String requestId);

  Future<void> removeFriend(String friendUserId);
}
