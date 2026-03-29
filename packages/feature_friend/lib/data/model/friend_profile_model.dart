import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_profile_model.freezed.dart';
part 'friend_profile_model.g.dart';

Object? _readDisplayName(Map json, String key) {
  return json[key] ?? json['username'];
}

@freezed
@JsonSerializable()
class FriendProfileModel with _$FriendProfileModel {
  const FriendProfileModel({
    required this.id,
    @JsonKey(name: 'display_name', readValue: _readDisplayName)
    this.displayName,
    this.username,
    @JsonKey(name: 'avatar_url') this.avatarUrl,
    this.bio,
    @JsonKey(name: 'last_seen_at') this.lastSeenAt,
  });

  factory FriendProfileModel.fromJson(Map<String, dynamic> json) =>
      _$FriendProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$FriendProfileModelToJson(this);

  @override
  final String id;
  @override
  final String? displayName;
  @override
  final String? username;
  @override
  final String? avatarUrl;
  @override
  final String? bio;
  @override
  final DateTime? lastSeenAt;
}
