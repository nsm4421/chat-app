import 'package:domodachi/features/friend/core/value_objects/friend_request_status.dart';
import 'package:domodachi/features/friend/data/model/friend_profile_model.dart';

final class FriendRequestModel {
  const FriendRequestModel({
    required this.id,
    required this.requesterId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.requester,
    required this.receiver,
    this.message,
    this.respondedAt,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['id'] as String,
      requesterId: json['requester_id'] as String,
      receiverId: json['receiver_id'] as String,
      status: FriendRequestStatus.values.byName(json['status'] as String),
      message: json['message'] as String?,
      respondedAt: json['responded_at'] == null
          ? null
          : DateTime.parse(json['responded_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      requester: FriendProfileModel.fromJson(
        Map<String, dynamic>.from(json['requester'] as Map),
      ),
      receiver: FriendProfileModel.fromJson(
        Map<String, dynamic>.from(json['receiver'] as Map),
      ),
    );
  }

  final String id;
  final String requesterId;
  final String receiverId;
  final FriendRequestStatus status;
  final String? message;
  final DateTime? respondedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final FriendProfileModel requester;
  final FriendProfileModel receiver;
}
