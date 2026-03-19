final class AuthUserModel {
  const AuthUserModel({
    required this.id,
    this.email,
    this.displayName,
    this.emailVerified = false,
    this.profileCompleted = false,
  });

  final String id;
  final String? email;
  final String? displayName;
  final bool emailVerified;
  final bool profileCompleted;
}
