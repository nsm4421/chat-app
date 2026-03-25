import 'dart:typed_data';

import 'package:domodachi/features/auth/data/model/auth_user_model.dart';

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

  Future<void> completeProfile({required String username});

  Future<void> updateProfile({
    required String username,
    Uint8List? avatarBytes,
    String? avatarFileExtension,
  });

  Future<bool> isUsernameAvailable(String username);
}
