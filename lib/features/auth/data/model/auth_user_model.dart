final class AuthUserModel {
  const AuthUserModel({
    required this.id,
    this.email,
    this.username,
    this.avatarUrl,
    this.emailVerified = false,
    this.profileCompleted = false,
  });

  final String id;
  final String? email;
  final String? username;
  final String? avatarUrl;
  final bool emailVerified;
  final bool profileCompleted;
}
