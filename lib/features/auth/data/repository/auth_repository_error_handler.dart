import 'package:domodachi/features/auth/data/exception/auth_data_exception.dart';
import 'package:domodachi/features/auth/domain/failure/auth_failure.dart';

mixin class AuthRepositoryErrorHandler {
  Future<T> guardAuthRequest<T>(
    Future<T> Function() action, {
    required String fallbackMessage,
  }) async {
    try {
      return await action();
    } on AuthDataException catch (error) {
      throw AuthFailure(mapAuthError(error.message));
    } catch (_) {
      throw AuthFailure(fallbackMessage);
    }
  }

  String mapAuthError(String rawMessage) {
    final message = rawMessage.toLowerCase();

    if (message.contains('invalid login credentials')) {
      return '이메일 또는 비밀번호를 확인해 주세요.';
    }
    if (message.contains('email not confirmed')) {
      return '이메일 인증 후 다시 시도해 주세요.';
    }
    if (message.contains('user already registered') ||
        message.contains('already been registered') ||
        message.contains('already registered')) {
      return '이미 가입된 이메일입니다. 로그인해 주세요.';
    }
    if (message.contains('password should be at least')) {
      return '비밀번호는 최소 6자 이상이어야 합니다.';
    }
    if (message.contains('unable to validate email address')) {
      return '올바른 이메일 주소를 입력해 주세요.';
    }

    return rawMessage;
  }
}
