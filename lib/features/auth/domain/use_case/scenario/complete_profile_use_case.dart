import 'package:domodachi/features/auth/domain/repository/auth_repository.dart';

final class CompleteProfileUseCase {
  CompleteProfileUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> call({required String displayName}) {
    return _authRepository.completeProfile(displayName: displayName);
  }
}
