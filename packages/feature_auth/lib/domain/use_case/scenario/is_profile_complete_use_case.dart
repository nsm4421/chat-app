import 'package:feature_auth/domain/entity/auth_user.dart';
import 'package:feature_auth/domain/repository/auth_repository.dart';

final class IsProfileCompleteUseCase {
  IsProfileCompleteUseCase(this._authRepository);

  final AuthRepository _authRepository;

  bool call(AuthUser user) => _authRepository.isProfileComplete(user);
}
