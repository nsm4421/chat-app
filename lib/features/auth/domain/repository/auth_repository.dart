import 'dart:typed_data';

import 'package:domodachi/features/auth/domain/entity/auth_user.dart';

abstract class AuthRepository {
  AuthUser? get currentUser;

  Stream<AuthUser?> get authStateChanges;

  bool isProfileComplete(AuthUser user);

  Future<void> signIn({required String email, required String password});

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
