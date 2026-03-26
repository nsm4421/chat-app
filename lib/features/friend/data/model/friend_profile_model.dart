final class FriendProfileModel {
  const FriendProfileModel({
    required this.id,
    this.displayName,
    this.username,
    this.avatarUrl,
    this.bio,
    this.lastSeenAt,
  });

  factory FriendProfileModel.fromJson(Map<String, dynamic> json) {
    return FriendProfileModel(
      id: json['id'] as String,
      displayName: (json['display_name'] ?? json['username']) as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      lastSeenAt: json['last_seen_at'] == null
          ? null
          : DateTime.parse(json['last_seen_at'] as String),
    );
  }

  final String id;
  final String? displayName;
  final String? username;
  final String? avatarUrl;
  final String? bio;
  final DateTime? lastSeenAt;

  FriendProfileModel copyWith({
    String? id,
    String? displayName,
    String? username,
    String? avatarUrl,
    String? bio,
    DateTime? lastSeenAt,
  }) {
    return FriendProfileModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }
}
