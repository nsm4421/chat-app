import 'package:domodachi/features/auth/domain/repository/auth_repository.dart';

final class DeleteAccountUseCase {
  DeleteAccountUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> call() => _authRepository.deleteAccount();
}
