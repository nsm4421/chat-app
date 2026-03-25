import 'package:domodachi/features/auth/domain/repository/auth_repository.dart';

final class IsUsernameAvailableUseCase {
  IsUsernameAvailableUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<bool> call(String username) {
    return _authRepository.isUsernameAvailable(username);
  }
}
