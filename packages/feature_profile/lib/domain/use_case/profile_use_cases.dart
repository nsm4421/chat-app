import 'package:feature_profile/domain/repository/profile_repository.dart';
import 'package:feature_profile/domain/use_case/scenario/complete_profile_use_case.dart';
import 'package:feature_profile/domain/use_case/scenario/is_username_available_use_case.dart';
import 'package:feature_profile/domain/use_case/scenario/update_profile_use_case.dart';
class ProfileUseCases {
  ProfileUseCases(this._repository);

  final ProfileRepository _repository;

  late final CompleteProfileUseCase _completeProfile = CompleteProfileUseCase(
    _repository,
  );
  late final UpdateProfileUseCase _updateProfile = UpdateProfileUseCase(
    _repository,
  );
  late final IsUsernameAvailableUseCase _isUsernameAvailable =
      IsUsernameAvailableUseCase(_repository);

  CompleteProfileUseCase get completeProfile => _completeProfile;
  UpdateProfileUseCase get updateProfile => _updateProfile;
  IsUsernameAvailableUseCase get isUsernameAvailable => _isUsernameAvailable;
}
