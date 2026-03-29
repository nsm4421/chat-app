import 'package:feature_chat_core/chat_core/domain/entity/chat_room_member.dart';
import 'package:feature_group_chat/group_chat/presentation/cubit/room/room_member_friend_cubit.dart';
import 'package:feature_group_chat/group_chat/presentation/cubit/room/room_member_friend_state.dart';
import 'package:feature_friend/core/value_objects/friend_request_status.dart';
import 'package:feature_friend/domain/entity/friend.dart';
import 'package:feature_friend/domain/entity/friend_candidate.dart';
import 'package:feature_friend/domain/entity/friend_profile.dart';
import 'package:feature_friend/domain/entity/friend_relationship.dart';
import 'package:feature_friend/domain/entity/friend_request.dart';
import 'package:feature_friend/domain/failure/friend_failure.dart';
import 'package:feature_friend/domain/repository/friend_repository.dart';
import 'package:feature_friend/domain/use_case/friend_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RoomMemberFriendCubit', () {
    late _FakeFriendRepository repository;
    late FriendUseCases friendUseCases;
    late RoomMemberFriendCubit cubit;

    setUp(() {
      repository = _FakeFriendRepository();
      friendUseCases = FriendUseCases(repository);
      cubit = RoomMemberFriendCubit(friendUseCases);
    });

    tearDown(() async {
      await cubit.close();
    });

    test('maps member relationships into button states', () async {
      repository.relationships = [
        const FriendRelationship(userId: 'friend-user', isFriend: true),
        const FriendRelationship(
          userId: 'sent-user',
          sentRequestId: 'sent-request',
        ),
        const FriendRelationship(
          userId: 'received-user',
          receivedRequestId: 'received-request',
        ),
      ];

      await cubit.syncMembers(
        members: [
          _member('me'),
          _member('friend-user'),
          _member('sent-user'),
          _member('received-user'),
          _member('new-user'),
        ],
        currentUserId: 'me',
      );

      expect(cubit.state.relations['me']?.status, RoomMemberFriendStatus.self);
      expect(
        cubit.state.relations['friend-user']?.status,
        RoomMemberFriendStatus.friend,
      );
      expect(
        cubit.state.relations['sent-user']?.status,
        RoomMemberFriendStatus.requestSent,
      );
      expect(
        cubit.state.relations['received-user']?.status,
        RoomMemberFriendStatus.requestReceived,
      );
      expect(
        cubit.state.relations['new-user']?.status,
        RoomMemberFriendStatus.canSendRequest,
      );
    });

    test('send and accept update member relationship state', () async {
      repository.relationships = const [
        FriendRelationship(userId: 'sender'),
        FriendRelationship(
          userId: 'receiver',
          receivedRequestId: 'incoming-request',
        ),
      ];

      await cubit.syncMembers(
        members: [_member('sender'), _member('receiver')],
        currentUserId: 'me',
      );

      await cubit.sendFriendRequest(
        member: _member('sender'),
        anonymousName: '익명 2',
      );
      await cubit.acceptFriendRequest(
        member: _member('receiver'),
        anonymousName: '익명 3',
      );

      expect(repository.sentReceiverUserIds, ['sender']);
      expect(repository.acceptedRequestIds, ['incoming-request']);
      expect(
        cubit.state.relations['sender']?.status,
        RoomMemberFriendStatus.requestSent,
      );
      expect(
        cubit.state.relations['receiver']?.status,
        RoomMemberFriendStatus.friend,
      );
    });

    test('send failure keeps specific error message for UI snackbar', () async {
      repository.relationships = const [
        FriendRelationship(userId: 'friend-user'),
      ];
      repository.sendFriendRequestError = const FriendFailure(
        '이미 친구 요청을 보낸 사용자예요.',
      );

      await cubit.syncMembers(
        members: [_member('friend-user')],
        currentUserId: 'me',
      );

      await cubit.sendFriendRequest(
        member: _member('friend-user'),
        anonymousName: '익명 2',
      );

      expect(cubit.state.errorMessage, '이미 친구 요청을 보낸 사용자예요.');
    });
  });
}

ChatRoomMember _member(String userId) {
  return ChatRoomMember(
    chatRoomId: 'room-1',
    userId: userId,
    isHost: false,
    joinedAt: DateTime(2026, 3, 26, 12),
  );
}

final class _FakeFriendRepository implements FriendRepository {
  List<FriendRelationship> relationships = const <FriendRelationship>[];
  List<String> sentReceiverUserIds = <String>[];
  List<String> acceptedRequestIds = <String>[];
  Object? sendFriendRequestError;

  @override
  Future<List<FriendRelationship>> fetchFriendRelationships({
    required List<String> userIds,
  }) async {
    return relationships
        .where((relationship) => userIds.contains(relationship.userId))
        .toList(growable: false);
  }

  @override
  Future<FriendRequest> sendFriendRequest({
    required String receiverUserId,
    String? message,
  }) async {
    final error = sendFriendRequestError;
    if (error != null) {
      throw error;
    }

    sentReceiverUserIds = [...sentReceiverUserIds, receiverUserId];
    return FriendRequest(
      id: 'request-$receiverUserId',
      requesterId: 'me',
      receiverId: receiverUserId,
      status: FriendRequestStatus.pending,
      createdAt: DateTime(2026, 3, 26, 12),
      updatedAt: DateTime(2026, 3, 26, 12),
      requester: const FriendProfile(id: 'me'),
      receiver: FriendProfile(id: receiverUserId),
    );
  }

  @override
  Future<void> acceptFriendRequest(String requestId) async {
    acceptedRequestIds = [...acceptedRequestIds, requestId];
  }

  @override
  Future<List<Friend>> fetchFriends({int limit = 20, String? cursor}) async =>
      const <Friend>[];

  @override
  Future<List<FriendRequest>> fetchReceivedFriendRequests({
    int limit = 20,
    String? cursor,
  }) async => const <FriendRequest>[];

  @override
  Future<List<FriendRequest>> fetchSentFriendRequests({
    int limit = 20,
    String? cursor,
  }) async => const <FriendRequest>[];

  @override
  Future<List<FriendCandidate>> searchFriendProfiles({
    required String query,
    int limit = 20,
  }) async => const <FriendCandidate>[];

  @override
  Future<void> declineFriendRequest(String requestId) async {}

  @override
  Future<void> cancelFriendRequest(String requestId) async {}

  @override
  Future<void> removeFriend(String friendUserId) async {}
}
