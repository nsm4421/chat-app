import 'package:domodachi/core/error/failure.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room_member.dart';
import 'package:domodachi/features/chat/presentation/cubit/room/room_member_friend_state.dart';
import 'package:domodachi/features/friend/domain/entity/friend_relationship.dart';
import 'package:domodachi/features/friend/domain/use_case/friend_use_cases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class RoomMemberFriendCubit extends Cubit<RoomMemberFriendState> {
  RoomMemberFriendCubit(this._friendUseCases)
    : super(RoomMemberFriendState.initial());

  final FriendUseCases _friendUseCases;

  Future<void> syncMembers({
    required List<ChatRoomMember> members,
    required String? currentUserId,
  }) async {
    if (currentUserId == null) {
      emit(
        state.copyWith(relations: const <String, RoomMemberFriendRelation>{}),
      );
      return;
    }

    try {
      final targetUserIds = members
          .map((member) => member.userId)
          .toSet()
          .toList(growable: false);
      final relationships = await _friendUseCases.fetchFriendRelationships(
        userIds: targetUserIds,
      );

      final relationshipByUserId = <String, FriendRelationship>{
        for (final relationship in relationships)
          relationship.userId: relationship,
      };

      final nextRelations = <String, RoomMemberFriendRelation>{};
      for (final member in members) {
        if (member.userId == currentUserId) {
          nextRelations[member.userId] = RoomMemberFriendRelation(
            userId: member.userId,
            status: RoomMemberFriendStatus.self,
          );
          continue;
        }

        final relationship = relationshipByUserId[member.userId];
        nextRelations[member.userId] = _toRelation(member.userId, relationship);
      }

      emit(state.copyWith(relations: nextRelations, errorMessage: null));
    } on Failure catch (error) {
      emit(state.copyWith(errorMessage: error.message));
    } catch (_) {
      emit(state.copyWith(errorMessage: '친구 상태를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.'));
    }
  }

  Future<void> sendFriendRequest({
    required ChatRoomMember member,
    required String anonymousName,
  }) async {
    final relation = state.relations[member.userId];
    if (relation == null ||
        relation.status != RoomMemberFriendStatus.canSendRequest) {
      return;
    }

    emit(
      state.copyWith(
        processingUserIds: {...state.processingUserIds, member.userId},
        errorMessage: null,
        noticeMessage: null,
      ),
    );

    try {
      final request = await _friendUseCases.sendFriendRequest(
        receiverUserId: member.userId,
      );
      emit(
        state.copyWith(
          relations: {
            ...state.relations,
            member.userId: RoomMemberFriendRelation(
              userId: member.userId,
              status: RoomMemberFriendStatus.requestSent,
              requestId: request.id,
            ),
          },
          processingUserIds: {...state.processingUserIds}
            ..remove(member.userId),
          noticeMessage: '$anonymousName에게 친구 요청을 보냈어요.',
        ),
      );
    } on Failure catch (error) {
      emit(
        state.copyWith(
          processingUserIds: {...state.processingUserIds}
            ..remove(member.userId),
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          processingUserIds: {...state.processingUserIds}
            ..remove(member.userId),
          errorMessage: '친구 요청을 보내지 못했어요. 잠시 후 다시 시도해 주세요.',
        ),
      );
    }
  }

  Future<void> acceptFriendRequest({
    required ChatRoomMember member,
    required String anonymousName,
  }) async {
    final relation = state.relations[member.userId];
    final requestId = relation?.requestId;
    if (relation == null ||
        relation.status != RoomMemberFriendStatus.requestReceived ||
        requestId == null) {
      return;
    }

    emit(
      state.copyWith(
        processingUserIds: {...state.processingUserIds, member.userId},
        errorMessage: null,
        noticeMessage: null,
      ),
    );

    try {
      await _friendUseCases.acceptFriendRequest(requestId);
      emit(
        state.copyWith(
          relations: {
            ...state.relations,
            member.userId: RoomMemberFriendRelation(
              userId: member.userId,
              status: RoomMemberFriendStatus.friend,
            ),
          },
          processingUserIds: {...state.processingUserIds}
            ..remove(member.userId),
          noticeMessage: '$anonymousName님과 친구가 되었어요.',
        ),
      );
    } on Failure catch (error) {
      emit(
        state.copyWith(
          processingUserIds: {...state.processingUserIds}
            ..remove(member.userId),
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          processingUserIds: {...state.processingUserIds}
            ..remove(member.userId),
          errorMessage: '친구 요청을 수락하지 못했어요. 잠시 후 다시 시도해 주세요.',
        ),
      );
    }
  }

  void clearFeedback() {
    emit(state.copyWith(errorMessage: null, noticeMessage: null));
  }

  RoomMemberFriendRelation _toRelation(
    String userId,
    FriendRelationship? relationship,
  ) {
    if (relationship == null) {
      return RoomMemberFriendRelation(
        userId: userId,
        status: RoomMemberFriendStatus.canSendRequest,
      );
    }

    if (relationship.isFriend) {
      return RoomMemberFriendRelation(
        userId: userId,
        status: RoomMemberFriendStatus.friend,
      );
    }

    if (relationship.hasReceivedPendingRequest) {
      return RoomMemberFriendRelation(
        userId: userId,
        status: RoomMemberFriendStatus.requestReceived,
        requestId: relationship.receivedRequestId,
      );
    }

    if (relationship.hasSentPendingRequest) {
      return RoomMemberFriendRelation(
        userId: userId,
        status: RoomMemberFriendStatus.requestSent,
        requestId: relationship.sentRequestId,
      );
    }

    return RoomMemberFriendRelation(
      userId: userId,
      status: RoomMemberFriendStatus.canSendRequest,
    );
  }
}
