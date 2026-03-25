import 'package:domodachi/features/friend/domain/entity/friend_profile.dart';

final class FriendCandidate {
  const FriendCandidate({
    required this.profile,
    required this.hasPendingRequest,
    required this.isFriend,
  });

  final FriendProfile profile;
  final bool hasPendingRequest;
  final bool isFriend;

  FriendCandidate copyWith({
    FriendProfile? profile,
    bool? hasPendingRequest,
    bool? isFriend,
  }) {
    return FriendCandidate(
      profile: profile ?? this.profile,
      hasPendingRequest: hasPendingRequest ?? this.hasPendingRequest,
      isFriend: isFriend ?? this.isFriend,
    );
  }
}
