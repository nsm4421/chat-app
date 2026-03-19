import 'package:domodachi/core/extensions/string_extension.dart';
import 'package:domodachi/features/auth/domain/validation/profile_field_rules.dart';

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
          ProfileFieldRules.passwordMinLength,
          message: '비밀번호는 ${ProfileFieldRules.passwordMinLength}자 이상이어야 합니다.',
        );
  }

  static String? displayName(String? value) {
    final displayName = value ?? '';

    final requiredMessage = displayName.validateRequired(
      message: '표시 이름을 입력해 주세요.',
    );
    if (requiredMessage != null) {
      return requiredMessage;
    }

    final minLengthMessage = displayName.validateMinLength(
      ProfileFieldRules.displayNameMinLength,
      message: '표시 이름은 ${ProfileFieldRules.displayNameMinLength}자 이상이어야 합니다.',
    );
    if (minLengthMessage != null) {
      return minLengthMessage;
    }

    if (displayName.trim().length > ProfileFieldRules.displayNameMaxLength) {
      return '표시 이름은 ${ProfileFieldRules.displayNameMaxLength}자 이하여야 합니다.';
    }

    return null;
  }

  static String? username(String? value) {
    final username = (value ?? '').trim();

    if (username.isEmpty) {
      return null;
    }
    if (!RegExp(ProfileFieldRules.usernamePattern).hasMatch(username)) {
      return '아이디는 영문 소문자, 숫자, 밑줄만 사용할 수 있으며 '
          '${ProfileFieldRules.usernameMinLength}-${ProfileFieldRules.usernameMaxLength}자여야 합니다.';
    }
    return null;
  }

  static String? bio(String? value) {
    final bio = value ?? '';

    if (bio.length > ProfileFieldRules.bioMaxLength) {
      return '소개는 ${ProfileFieldRules.bioMaxLength}자 이하여야 합니다.';
    }
    return null;
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
