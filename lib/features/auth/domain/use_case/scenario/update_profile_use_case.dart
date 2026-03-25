import 'dart:typed_data';

import 'package:domodachi/features/auth/domain/repository/auth_repository.dart';

final class UpdateProfileUseCase {
  UpdateProfileUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> call({
    required String username,
    Uint8List? avatarBytes,
    String? avatarFileExtension,
  }) {
    return _authRepository.updateProfile(
      username: username,
      avatarBytes: avatarBytes,
      avatarFileExtension: avatarFileExtension,
    );
  }
}
