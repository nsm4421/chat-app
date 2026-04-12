import 'dart:typed_data';

import 'package:feature_profile/data/data_source/profile_data_source.dart';
import 'package:feature_profile/data/repository/profile_repository_error_handler.dart';
import 'package:feature_profile/domain/repository/profile_repository.dart';
class ProfileRepositoryImpl
    with ProfileRepositoryErrorHandler
    implements ProfileRepository {
  ProfileRepositoryImpl(this._profileDataSource);

  final ProfileDataSource _profileDataSource;

  @override
  Future<void> completeProfile({required String username}) {
    return guardProfileRequest(
      () => _profileDataSource.completeProfile(username: username),
      fallbackMessage: '프로필 저장 중 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.',
    );
  }

  @override
  Future<bool> isUsernameAvailable(String username) {
    return guardProfileRequest(
      () => _profileDataSource.isUsernameAvailable(username),
      fallbackMessage: '아이디 중복 여부를 확인하지 못했습니다. 잠시 후 다시 시도해 주세요.',
    );
  }

  @override
  Future<void> updateProfile({
    required String username,
    Uint8List? avatarBytes,
    String? avatarFileExtension,
  }) {
    return guardProfileRequest(
      () => _profileDataSource.updateProfile(
        username: username,
        avatarBytes: avatarBytes,
        avatarFileExtension: avatarFileExtension,
      ),
      fallbackMessage: '프로필 수정 중 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.',
    );
  }
}
