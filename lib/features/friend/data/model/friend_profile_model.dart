final class FriendProfileModel {
  const FriendProfileModel({
    required this.id,
    this.displayName,
    this.username,
    this.avatarUrl,
    this.bio,
  });

  factory FriendProfileModel.fromJson(Map<String, dynamic> json) {
    return FriendProfileModel(
      id: json['id'] as String,
      displayName: (json['display_name'] ?? json['username']) as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
    );
  }

  final String id;
  final String? displayName;
  final String? username;
  final String? avatarUrl;
  final String? bio;
}
