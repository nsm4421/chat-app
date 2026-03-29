import 'package:feature_auth/data/model/auth_user_model.dart';

abstract interface class AuthDataSource {
  AuthUserModel? get currentUser;

  Stream<AuthUserModel?> get authStateChanges;

  Future<void> signInWithPassword({
    required String email,
    required String password,
  });

  Future<void> signUp({required String email, required String password});

  Future<void> signOut();

  Future<void> deleteAccount();

  Future<void> sendPasswordResetEmail(String email);
}
