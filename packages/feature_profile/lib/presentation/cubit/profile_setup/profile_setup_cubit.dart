import 'package:feature_profile/domain/use_case/profile_use_cases.dart';
import 'package:feature_profile/presentation/cubit/base/profile_request_cubit.dart';
class ProfileSetupCubit extends ProfileRequestCubit {
  ProfileSetupCubit(this._profileUseCases);

  final ProfileUseCases _profileUseCases;

  Future<void> submitProfile(String username) {
    return run(
      () => _profileUseCases.completeProfile(username: username.trim()),
    );
  }
}
