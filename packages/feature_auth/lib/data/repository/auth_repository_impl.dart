import 'package:feature_auth/data/data_source/auth_data_source.dart';
import 'package:feature_auth/data/mapper/auth_user_mapper.dart';
import 'package:feature_auth/data/repository/auth_repository_error_handler.dart';
import 'package:feature_auth/domain/entity/auth_user.dart';
import 'package:feature_auth/domain/repository/auth_repository.dart';
class AuthRepositoryImpl
    with AuthRepositoryErrorHandler
    implements AuthRepository {
  AuthRepositoryImpl(this._authDataSource);

  final AuthDataSource _authDataSource;

  @override
  AuthUser? get currentUser => _authDataSource.currentUser?.toAuthUser();

  @override
  Stream<AuthUser?> get authStateChanges =>
      _authDataSource.authStateChanges.map((user) => user?.toAuthUser());

  @override
  bool isProfileComplete(AuthUser user) => user.isProfileComplete;

  @override
  Future<void> signIn({required String email, required String password}) async {
    await guardAuthRequest(() async {
      await _authDataSource.signInWithPassword(
        email: email,
        password: password,
      );
    }, fallbackMessage: '로그인 중 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.');
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    await guardAuthRequest(() async {
      await _authDataSource.signUp(email: email, password: password);
    }, fallbackMessage: '회원가입 중 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.');
  }

  @override
  Future<void> signOut() async {
    await guardAuthRequest(
      _authDataSource.signOut,
      fallbackMessage: '로그아웃 중 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.',
    );
  }

  @override
  Future<void> deleteAccount() async {
    await guardAuthRequest(
      _authDataSource.deleteAccount,
      fallbackMessage: '탈퇴 처리 중 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.',
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await guardAuthRequest(
      () => _authDataSource.sendPasswordResetEmail(email),
      fallbackMessage: '비밀번호 재설정 메일을 보내는 중 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.',
    );
  }
}
