import 'package:feature_auth/domain/entity/auth_user.dart';
import 'package:feature_auth/domain/repository/auth_repository.dart';

final class GetCurrentUserUseCase {
  GetCurrentUserUseCase(this._authRepository);

  final AuthRepository _authRepository;

  AuthUser? call() => _authRepository.currentUser;
}
