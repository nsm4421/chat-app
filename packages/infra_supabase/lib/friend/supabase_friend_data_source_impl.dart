import 'package:feature_friend/data/data_source/friend_data_source.dart';
import 'package:feature_friend/data/model/friend_candidate_model.dart';
import 'package:feature_friend/data/model/friend_model.dart';
import 'package:feature_friend/data/model/friend_profile_model.dart';
import 'package:feature_friend/data/model/friend_relationship_model.dart';
import 'package:feature_friend/data/model/friend_request_model.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase/supabase.dart';

import 'supabase_friend_data_source_handler.dart';

@LazySingleton(as: FriendDataSource)
class SupabaseFriendDataSourceImpl
    with SupabaseFriendDataSourceHandler
    implements FriendDataSource {
  SupabaseFriendDataSourceImpl(this._client);

  static const _friendRequestsTable = 'friend_requests';
  static const _friendshipsTable = 'friendships';
  static const _userAccountStateTable = 'user_account_state';
  static const _requestProfileColumns = 'id, username, avatar_url';
  static const _friendshipProfileColumns = 'id, username, avatar_url, bio';

  final SupabaseClient _client;

  @override
  Future<Iterable<FriendModel>> fetchFriends({int limit = 20, String? cursor}) {
    return guardFriendRequest(() async {
      final currentUserId = requireCurrentUserId(_client);

      dynamic query = _client
          .from(_friendshipsTable)
          .select(
            'user_a_id, user_b_id, created_at, '
            'user_a:profiles!friendships_user_a_id_fkey($_friendshipProfileColumns), '
            'user_b:profiles!friendships_user_b_id_fkey($_friendshipProfileColumns)',
          )
          .or('user_a_id.eq.$currentUserId,user_b_id.eq.$currentUserId');

      if (cursor != null) {
        query = query.lt('created_at', cursor);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      if (response is! List) {
        return const <FriendModel>[];
      }

      final rows = response
          .map((row) => Map<String, dynamic>.from(row as Map))
          .toList(growable: false);
      final friendIds = rows
          .map((json) {
            final userAId = json['user_a_id'] as String;
            final userBId = json['user_b_id'] as String;
            return userAId == currentUserId ? userBId : userAId;
          })
          .toSet()
          .toList(growable: false);
      final lastSeenAtByUserId = await _fetchLastSeenAtByUserId(friendIds);

      return rows
          .map((json) {
            final userA = FriendProfileModel.fromJson(
              Map<String, dynamic>.from(json['user_a'] as Map),
            );
            final userB = FriendProfileModel.fromJson(
              Map<String, dynamic>.from(json['user_b'] as Map),
            );
            final baseProfile = userA.id == currentUserId ? userB : userA;
            final profile = baseProfile.copyWith(
              lastSeenAt: lastSeenAtByUserId[baseProfile.id],
            );
            return FriendModel(
              profile: profile,
              createdAt: DateTime.parse(json['created_at'] as String),
            );
          })
          .toList(growable: false);
    });
  }

  @override
  Future<Iterable<FriendRequestModel>> fetchReceivedFriendRequests({
    int limit = 20,
    String? cursor,
  }) {
    return guardFriendRequest(() async {
      final currentUserId = requireCurrentUserId(_client);

      dynamic query = _client
          .from(_friendRequestsTable)
          .select(
            'id, requester_id, receiver_id, status, message, responded_at, '
            'created_at, updated_at, '
            'requester:profiles!friend_requests_requester_id_fkey($_requestProfileColumns), '
            'receiver:profiles!friend_requests_receiver_id_fkey($_requestProfileColumns)',
          )
          .eq('receiver_id', currentUserId)
          .eq('status', 'pending');

      if (cursor != null) {
        query = query.lt('created_at', cursor);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return _toFriendRequests(response);
    });
  }

  @override
  Future<Iterable<FriendRequestModel>> fetchSentFriendRequests({
    int limit = 20,
    String? cursor,
  }) {
    return guardFriendRequest(() async {
      final currentUserId = requireCurrentUserId(_client);

      dynamic query = _client
          .from(_friendRequestsTable)
          .select(
            'id, requester_id, receiver_id, status, message, responded_at, '
            'created_at, updated_at, '
            'requester:profiles!friend_requests_requester_id_fkey($_requestProfileColumns), '
            'receiver:profiles!friend_requests_receiver_id_fkey($_requestProfileColumns)',
          )
          .eq('requester_id', currentUserId)
          .eq('status', 'pending');

      if (cursor != null) {
        query = query.lt('created_at', cursor);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return _toFriendRequests(response);
    });
  }

  @override
  Future<Iterable<FriendRelationshipModel>> fetchFriendRelationships({
    required List<String> userIds,
  }) {
    return guardFriendRequest(() async {
      final currentUserId = requireCurrentUserId(_client);
      final normalizedUserIds = userIds
          .toSet()
          .where((userId) => userId != currentUserId)
          .toList(growable: false);

      if (normalizedUserIds.isEmpty) {
        return const <FriendRelationshipModel>[];
      }

      final relationships = <String, FriendRelationshipModel>{
        for (final userId in normalizedUserIds)
          userId: FriendRelationshipModel(userId: userId),
      };

      final friendshipsAsUserA = await _client
          .from(_friendshipsTable)
          .select('user_b_id')
          .eq('user_a_id', currentUserId)
          .inFilter('user_b_id', normalizedUserIds);
      for (final row in friendshipsAsUserA) {
        final userId = (row as Map)['user_b_id'] as String;
        relationships[userId] = FriendRelationshipModel(
          userId: userId,
          isFriend: true,
          sentRequestId: relationships[userId]?.sentRequestId,
          receivedRequestId: relationships[userId]?.receivedRequestId,
        );
      }

      final friendshipsAsUserB = await _client
          .from(_friendshipsTable)
          .select('user_a_id')
          .eq('user_b_id', currentUserId)
          .inFilter('user_a_id', normalizedUserIds);
      for (final row in friendshipsAsUserB) {
        final userId = (row as Map)['user_a_id'] as String;
        relationships[userId] = FriendRelationshipModel(
          userId: userId,
          isFriend: true,
          sentRequestId: relationships[userId]?.sentRequestId,
          receivedRequestId: relationships[userId]?.receivedRequestId,
        );
      }

      final sentRequests = await _client
          .from(_friendRequestsTable)
          .select('id, receiver_id')
          .eq('requester_id', currentUserId)
          .eq('status', 'pending')
          .inFilter('receiver_id', normalizedUserIds);
      for (final row in sentRequests) {
        final json = Map<String, dynamic>.from(row as Map);
        final userId = json['receiver_id'] as String;
        final current = relationships[userId]!;
        relationships[userId] = FriendRelationshipModel(
          userId: userId,
          isFriend: current.isFriend,
          sentRequestId: json['id'] as String,
          receivedRequestId: current.receivedRequestId,
        );
      }

      final receivedRequests = await _client
          .from(_friendRequestsTable)
          .select('id, requester_id')
          .eq('receiver_id', currentUserId)
          .eq('status', 'pending')
          .inFilter('requester_id', normalizedUserIds);
      for (final row in receivedRequests) {
        final json = Map<String, dynamic>.from(row as Map);
        final userId = json['requester_id'] as String;
        final current = relationships[userId]!;
        relationships[userId] = FriendRelationshipModel(
          userId: userId,
          isFriend: current.isFriend,
          sentRequestId: current.sentRequestId,
          receivedRequestId: json['id'] as String,
        );
      }

      return relationships.values.toList(growable: false);
    });
  }

  @override
  Future<Iterable<FriendCandidateModel>> searchFriendProfiles({
    required String query,
    int limit = 20,
  }) {
    return guardFriendRequest(() async {
      requireCurrentUserId(_client);

      final response = await _client.rpc(
        'search_friend_profiles',
        params: {'keyword': query.trim(), 'limit_count': limit},
      );

      if (response is! List) {
        return const <FriendCandidateModel>[];
      }

      return response
          .map((row) {
            final json = Map<String, dynamic>.from(row as Map);
            return FriendCandidateModel.fromJson({
              ...json,
              'profile': json,
            });
          })
          .toList(growable: false);
    });
  }

  @override
  Future<FriendRequestModel> sendFriendRequest({
    required String receiverUserId,
    String? message,
  }) {
    return guardFriendRequest(() async {
      requireCurrentUserId(_client);

      final response = await _client.rpc(
        'send_friend_request',
        params: {
          'receiver_user_id': receiverUserId,
          'request_message': message?.trim(),
        },
      );

      final requestJson = Map<String, dynamic>.from(response as Map);
      final createdRequestId = requestJson['id'] as String;

      final createdRequest = await _client
          .from(_friendRequestsTable)
          .select(
            'id, requester_id, receiver_id, status, message, responded_at, '
            'created_at, updated_at, '
            'requester:profiles!friend_requests_requester_id_fkey($_requestProfileColumns), '
            'receiver:profiles!friend_requests_receiver_id_fkey($_requestProfileColumns)',
          )
          .eq('id', createdRequestId)
          .single();

      return FriendRequestModel.fromJson(
        Map<String, dynamic>.from(createdRequest as Map),
      );
    });
  }

  @override
  Future<void> acceptFriendRequest(String requestId) {
    return guardFriendRequest(() async {
      requireCurrentUserId(_client);
      await _client.rpc(
        'accept_friend_request',
        params: {'friend_request_id': requestId},
      );
    });
  }

  @override
  Future<void> declineFriendRequest(String requestId) {
    return guardFriendRequest(() async {
      requireCurrentUserId(_client);
      await _client.rpc(
        'decline_friend_request',
        params: {'friend_request_id': requestId},
      );
    });
  }

  @override
  Future<void> cancelFriendRequest(String requestId) {
    return guardFriendRequest(() async {
      requireCurrentUserId(_client);
      await _client.rpc(
        'cancel_friend_request',
        params: {'friend_request_id': requestId},
      );
    });
  }

  @override
  Future<void> removeFriend(String friendUserId) {
    return guardFriendRequest(() async {
      requireCurrentUserId(_client);
      await _client.rpc(
        'remove_friend',
        params: {'friend_user_id': friendUserId},
      );
    });
  }

  List<FriendRequestModel> _toFriendRequests(dynamic response) {
    if (response is! List) {
      return const <FriendRequestModel>[];
    }

    return response
        .map(
          (row) => FriendRequestModel.fromJson(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList(growable: false);
  }

  Future<Map<String, DateTime?>> _fetchLastSeenAtByUserId(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) {
      return const <String, DateTime?>{};
    }

    final response = await _client
        .from(_userAccountStateTable)
        .select('user_id, last_seen_at')
        .inFilter('user_id', userIds);

    final result = <String, DateTime?>{};
    for (final row in response) {
      final json = Map<String, dynamic>.from(row as Map);
      result[json['user_id'] as String] = json['last_seen_at'] == null
          ? null
          : DateTime.parse(json['last_seen_at'] as String);
    }

    return result;
  }
}
