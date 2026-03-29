import 'package:feature_friend/data/model/friend_profile_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_candidate_model.freezed.dart';
part 'friend_candidate_model.g.dart';

Object? _readProfile(Map json, String _) => json;

FriendProfileModel _profileFromJson(Object? json) {
  return FriendProfileModel.fromJson(
    Map<String, dynamic>.from(json as Map),
  );
}

@freezed
@JsonSerializable()
class FriendCandidateModel with _$FriendCandidateModel {
  const FriendCandidateModel({
    @JsonKey(readValue: _readProfile, fromJson: _profileFromJson)
    required this.profile,
    @Default(false) @JsonKey(name: 'has_pending_request') this.hasPendingRequest = false,
    @Default(false) @JsonKey(name: 'is_friend') this.isFriend = false,
  });

  factory FriendCandidateModel.fromJson(Map<String, dynamic> json) =>
      _$FriendCandidateModelFromJson(json);

  Map<String, dynamic> toJson() => _$FriendCandidateModelToJson(this);

  @override
  final FriendProfileModel profile;
  @override
  final bool hasPendingRequest;
  @override
  final bool isFriend;
}
