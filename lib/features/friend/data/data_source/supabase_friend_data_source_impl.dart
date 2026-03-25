import 'package:domodachi/features/friend/data/data_source/friend_data_source.dart';
import 'package:domodachi/features/friend/data/data_source/supabase_friend_data_source_handler.dart';
import 'package:domodachi/features/friend/data/model/friend_candidate_model.dart';
import 'package:domodachi/features/friend/data/model/friend_model.dart';
import 'package:domodachi/features/friend/data/model/friend_profile_model.dart';
import 'package:domodachi/features/friend/data/model/friend_request_model.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: FriendDataSource)
class SupabaseFriendDataSourceImpl
    with SupabaseFriendDataSourceHandler
    implements FriendDataSource {
  SupabaseFriendDataSourceImpl(this._client);

  static const _friendRequestsTable = 'friend_requests';
  static const _friendshipsTable = 'friendships';
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

      return response
          .map((row) {
            final json = Map<String, dynamic>.from(row as Map);
            final userA = FriendProfileModel.fromJson(
              Map<String, dynamic>.from(json['user_a'] as Map),
            );
            final userB = FriendProfileModel.fromJson(
              Map<String, dynamic>.from(json['user_b'] as Map),
            );
            final profile = userA.id == currentUserId ? userB : userA;
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
          .eq('receiver_id', currentUserId);

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
          .eq('requester_id', currentUserId);

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
          .map(
            (row) => FriendCandidateModel.fromJson(
              Map<String, dynamic>.from(row as Map),
            ),
          )
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
}
