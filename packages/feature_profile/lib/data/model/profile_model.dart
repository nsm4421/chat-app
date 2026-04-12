class ProfileModel {
  final String id;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final bool onBoardingCompleted;
  final String createdAt;

  ProfileModel({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.bio,
    this.onBoardingCompleted = true,
    required this.createdAt,
  });
}
