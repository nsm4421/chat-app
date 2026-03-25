import 'package:domodachi/features/auth/domain/repository/auth_repository.dart';

final class CompleteProfileUseCase {
  CompleteProfileUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> call({required String username}) {
    return _authRepository.completeProfile(username: username);
  }
}
