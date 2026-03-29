import 'package:shared/shared.dart';

final class AuthInputValidator {
  const AuthInputValidator._();

  static String? email(String? value) {
    final email = value ?? '';

    final requiredMessage = email.validateRequired(message: '이메일을 입력해 주세요.');
    if (requiredMessage != null) {
      return requiredMessage;
    }
    if (!email.isValidEmail) {
      return '올바른 이메일 형식이 아닙니다.';
    }
    return null;
  }

  static String? password(String? value) {
    final password = value ?? '';

    return password.validateRequired(message: '비밀번호를 입력해 주세요.') ??
        password.validateMinLength(
          6,
          message: '비밀번호는 6자 이상이어야 합니다.',
        );
  }

  static String? confirmPassword({
    required String? value,
    required String password,
  }) {
    final confirmPassword = value ?? '';

    final requiredMessage = confirmPassword.validateRequired(
      message: '비밀번호 확인을 입력해 주세요.',
    );
    if (requiredMessage != null) {
      return requiredMessage;
    }
    if (confirmPassword != password) {
      return '비밀번호가 일치하지 않습니다.';
    }
    return null;
  }
}
