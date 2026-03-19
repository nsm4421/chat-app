import 'package:domodachi/features/auth/domain/use_case/auth_use_cases.dart';
import 'package:domodachi/features/auth/presentation/cubit/base/auth_request_cubit.dart';
import 'package:injectable/injectable.dart';

@injectable
class SignUpCubit extends AuthRequestCubit {
  SignUpCubit(this._authUseCases);

  final AuthUseCases _authUseCases;

  Future<void> signUp({required String email, required String password}) {
    return run(
      () => _authUseCases.signUp(email: email.trim(), password: password),
      successMessage: '회원가입이 완료되었어요.',
    );
  }
}
