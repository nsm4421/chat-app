import 'dart:typed_data';

import 'package:feature_profile/domain/repository/profile_repository.dart';

final class UpdateProfileUseCase {
  UpdateProfileUseCase(this._profileRepository);

  final ProfileRepository _profileRepository;

  Future<void> call({
    required String username,
    Uint8List? avatarBytes,
    String? avatarFileExtension,
  }) {
    return _profileRepository.updateProfile(
      username: username,
      avatarBytes: avatarBytes,
      avatarFileExtension: avatarFileExtension,
    );
  }
}
