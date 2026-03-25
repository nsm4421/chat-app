import 'dart:typed_data';

import 'package:domodachi/features/auth/domain/use_case/auth_use_cases.dart';
import 'package:domodachi/features/auth/presentation/cubit/base/auth_request_cubit.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProfileEditCubit extends AuthRequestCubit {
  ProfileEditCubit(this._authUseCases);

  final AuthUseCases _authUseCases;

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
      () => _authUseCases.updateProfile(
        username: normalizedUsername,
        avatarBytes: avatarBytes,
        avatarFileExtension: avatarFileExtension,
      ),
      successMessage: '프로필을 수정했어요.',
    );
  }
}
