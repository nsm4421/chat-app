import 'package:domodachi/features/auth/domain/use_case/auth_use_cases.dart';
import 'package:domodachi/features/auth/presentation/cubit/base/auth_request_cubit.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProfileSetupCubit extends AuthRequestCubit {
  ProfileSetupCubit(this._authUseCases);

  final AuthUseCases _authUseCases;

  Future<void> submitProfile(String username) {
    return run(
      () => _authUseCases.completeProfile(username: username.trim()),
    );
  }
}
