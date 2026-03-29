import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';

@freezed
class AuthUser with _$AuthUser {
  const AuthUser({
    required this.id,
    this.email,
    this.username,
    this.avatarUrl,
    this.emailVerified = false,
    this.profileCompleted = false,
  });

  @override
  final String id;

  @override
  final String? email;

  @override
  final String? username;

  @override
  final String? avatarUrl;

  @override
  final bool emailVerified;

  @override
  final bool profileCompleted;

  bool get isProfileComplete =>
      profileCompleted && (username?.trim().isNotEmpty ?? false);
}
