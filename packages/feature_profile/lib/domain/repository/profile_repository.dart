import 'dart:typed_data';

abstract class ProfileRepository {
  Future<void> completeProfile({required String username});

  Future<void> updateProfile({
    required String username,
    Uint8List? avatarBytes,
    String? avatarFileExtension,
  });

  Future<bool> isUsernameAvailable(String username);
}
