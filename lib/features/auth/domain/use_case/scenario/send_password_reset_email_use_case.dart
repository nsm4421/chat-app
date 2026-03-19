import 'package:domodachi/features/auth/domain/repository/auth_repository.dart';

final class SendPasswordResetEmailUseCase {
  SendPasswordResetEmailUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> call(String email) {
    return _authRepository.sendPasswordResetEmail(email);
  }
}
