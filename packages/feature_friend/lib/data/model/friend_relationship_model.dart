import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_relationship_model.freezed.dart';

@freezed
class FriendRelationshipModel with _$FriendRelationshipModel {
  const FriendRelationshipModel({
    required this.userId,
    @Default(false) this.isFriend = false,
    this.sentRequestId,
    this.receivedRequestId,
  });

  @override
  final String userId;
  @override
  final bool isFriend;
  @override
  final String? sentRequestId;
  @override
  final String? receivedRequestId;
}
