final class FriendProfile {
  const FriendProfile({
    required this.id,
    this.displayName,
    this.username,
    this.avatarUrl,
    this.bio,
    this.lastSeenAt,
  });

  final String id;
  final String? displayName;
  final String? username;
  final String? avatarUrl;
  final String? bio;
  final DateTime? lastSeenAt;
}
