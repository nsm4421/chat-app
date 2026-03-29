import 'package:feature_profile/domain/repository/profile_repository.dart';

final class IsUsernameAvailableUseCase {
  IsUsernameAvailableUseCase(this._profileRepository);

  final ProfileRepository _profileRepository;

  Future<bool> call(String username) {
    return _profileRepository.isUsernameAvailable(username);
  }
}
