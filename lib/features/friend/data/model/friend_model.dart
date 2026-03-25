import 'package:domodachi/features/friend/data/model/friend_profile_model.dart';

final class FriendModel {
  const FriendModel({required this.profile, required this.createdAt});

  final FriendProfileModel profile;
  final DateTime createdAt;
}
