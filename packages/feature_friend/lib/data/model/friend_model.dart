import 'package:feature_friend/data/model/friend_profile_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_model.freezed.dart';

@freezed
class FriendModel with _$FriendModel {
  const FriendModel({
    required this.profile,
    required this.createdAt,
  });

  @override
  final FriendProfileModel profile;
  @override
  final DateTime createdAt;
}
