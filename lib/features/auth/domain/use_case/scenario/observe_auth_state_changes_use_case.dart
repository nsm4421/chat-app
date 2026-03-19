import 'package:domodachi/features/auth/domain/entity/auth_user.dart';
import 'package:domodachi/features/auth/domain/repository/auth_repository.dart';

final class ObserveAuthStateChangesUseCase {
  ObserveAuthStateChangesUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Stream<AuthUser?> call() => _authRepository.authStateChanges;
}
