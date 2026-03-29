abstract final class ProfileFieldRules {
  static const passwordMinLength = 6;

  static const displayNameMinLength = 2;
  static const displayNameMaxLength = 30;

  static const usernameMinLength = 3;
  static const usernameMaxLength = 20;
  static const usernamePattern = r'^[a-z0-9_]{3,20}$';

  static const bioMaxLength = 160;
}
