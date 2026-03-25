import 'package:domodachi/features/friend/data/model/friend_profile_model.dart';

final class FriendCandidateModel {
  const FriendCandidateModel({
    required this.profile,
    required this.hasPendingRequest,
    required this.isFriend,
  });

  factory FriendCandidateModel.fromJson(Map<String, dynamic> json) {
    return FriendCandidateModel(
      profile: FriendProfileModel.fromJson(json),
      hasPendingRequest: json['has_pending_request'] as bool? ?? false,
      isFriend: json['is_friend'] as bool? ?? false,
    );
  }

  final FriendProfileModel profile;
  final bool hasPendingRequest;
  final bool isFriend;
}
