import 'dart:typed_data';

import 'package:feature_profile/domain/use_case/profile_use_cases.dart';
import 'package:feature_profile/presentation/cubit/base/profile_request_cubit.dart';
class ProfileEditCubit extends ProfileRequestCubit {
  ProfileEditCubit(this._profileUseCases);

  final ProfileUseCases _profileUseCases;

  Future<void> submitProfile({
    required String initialUsername,
    required String username,
    Uint8List? avatarBytes,
    String? avatarFileExtension,
  }) {
    final normalizedInitialUsername = initialUsername.trim();
    final normalizedUsername = username.trim();
    final hasUsernameChanged = normalizedUsername != normalizedInitialUsername;
    final hasAvatarChanged = avatarBytes != null;

    if (!hasUsernameChanged && !hasAvatarChanged) {
      return Future.value();
    }

    return run(
      () => _profileUseCases.updateProfile(
        username: normalizedUsername,
        avatarBytes: avatarBytes,
        avatarFileExtension: avatarFileExtension,
      ),
      successMessage: '프로필을 수정했어요.',
    );
  }
}
