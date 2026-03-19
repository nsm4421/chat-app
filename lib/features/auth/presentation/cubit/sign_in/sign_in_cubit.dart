import 'package:domodachi/features/auth/domain/use_case/auth_use_cases.dart';
import 'package:domodachi/features/auth/presentation/cubit/base/auth_request_cubit.dart';
import 'package:injectable/injectable.dart';

@injectable
class SignInCubit extends AuthRequestCubit {
  SignInCubit(this._authUseCases);

  final AuthUseCases _authUseCases;

  Future<void> signIn({required String email, required String password}) {
    return run(
      () => _authUseCases.signIn(email: email.trim(), password: password),
    );
  }
}
