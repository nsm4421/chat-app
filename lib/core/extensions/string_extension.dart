extension StringExtension on String {
  static final RegExp _emailRegex = RegExp(
    r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
    caseSensitive: false,
  );

  String get trimmed => trim();
  bool get isBlank => trimmed.isEmpty;
  bool get isNotBlank => !isBlank;
  String? get nullIfBlank => isBlank ? null : trimmed;
  bool get isValidEmail => _emailRegex.hasMatch(trimmed);

  String? validateRequired({String message = '값을 입력해 주세요.'}) {
    if (isBlank) {
      return message;
    }
    return null;
  }

  String? validateMinLength(int minLength, {required String message}) {
    if (trimmed.length < minLength) {
      return message;
    }
    return null;
  }
}
