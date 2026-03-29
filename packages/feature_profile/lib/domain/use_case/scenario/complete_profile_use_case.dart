import 'package:feature_profile/domain/repository/profile_repository.dart';

final class CompleteProfileUseCase {
  CompleteProfileUseCase(this._profileRepository);

  final ProfileRepository _profileRepository;

  Future<void> call({required String username}) {
    return _profileRepository.completeProfile(username: username);
  }
}
