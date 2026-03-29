import 'package:feature_friend/core/value_objects/friend_request_status.dart';
import 'package:feature_friend/data/model/friend_profile_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_request_model.freezed.dart';
part 'friend_request_model.g.dart';

@freezed
@JsonSerializable()
class FriendRequestModel with _$FriendRequestModel {
  const FriendRequestModel({
    required this.id,
    @JsonKey(name: 'requester_id') required this.requesterId,
    @JsonKey(name: 'receiver_id') required this.receiverId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.requester,
    required this.receiver,
    this.message,
    @JsonKey(name: 'responded_at') this.respondedAt,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) =>
      _$FriendRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$FriendRequestModelToJson(this);

  @override
  final String id;
  @override
  final String requesterId;
  @override
  final String receiverId;
  @override
  final FriendRequestStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final FriendProfileModel requester;
  @override
  final FriendProfileModel receiver;
  @override
  final String? message;
  @override
  final DateTime? respondedAt;
}
