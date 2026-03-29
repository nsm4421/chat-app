import 'package:shared/shared.dart';
import 'package:feature_profile/domain/validation/profile_field_rules.dart';

final class ProfileInputValidator {
  const ProfileInputValidator._();

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

  static String? bio(String? value) {
    final bio = value ?? '';

    if (bio.length > ProfileFieldRules.bioMaxLength) {
      return '소개는 ${ProfileFieldRules.bioMaxLength}자 이하여야 합니다.';
    }
    return null;
  }
}
