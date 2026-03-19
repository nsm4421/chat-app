import 'package:domodachi/features/auth/domain/repository/auth_repository.dart';

final class SignUpUseCase {
  SignUpUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> call({required String email, required String password}) {
    return _authRepository.signUp(email: email, password: password);
  }
}
