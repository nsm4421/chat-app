import 'package:domodachi/features/friend/domain/entity/friend_profile.dart';

final class Friend {
  const Friend({required this.profile, required this.createdAt});

  final FriendProfile profile;
  final DateTime createdAt;
}
