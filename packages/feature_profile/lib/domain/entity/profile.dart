class Profile {
  final String id;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final String createdAt;

  Profile({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.bio,
    required this.createdAt,
  });
}
