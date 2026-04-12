import 'package:feature_auth/domain/use_case/auth_use_cases.dart';
import 'package:feature_auth/presentation/cubit/base/auth_request_cubit.dart';
class PasswordResetCubit extends AuthRequestCubit {
  PasswordResetCubit(this._authUseCases);

  final AuthUseCases _authUseCases;

  Future<void> sendResetEmail(String email) {
    return run(
      () => _authUseCases.sendPasswordResetEmail(email.trim()),
      successMessage: '비밀번호 재설정 메일을 전송했습니다.',
    );
  }
}
