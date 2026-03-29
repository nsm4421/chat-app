import 'package:feature_auth/data/model/auth_user_model.dart';
import 'package:feature_auth/domain/entity/auth_user.dart';

extension AuthUserModelMapper on AuthUserModel {
  AuthUser toAuthUser() {
    return AuthUser(
      id: id,
      email: email,
      username: username,
      avatarUrl: avatarUrl,
      emailVerified: emailVerified,
      profileCompleted: profileCompleted,
    );
  }
}
