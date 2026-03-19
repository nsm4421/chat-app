import 'package:domodachi/core/extensions/string_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StringExtension', () {
    test('trimmed returns a string without edge whitespace', () {
      expect('  domodachi  '.trimmed, 'domodachi');
    });

    test('isBlank and nullIfBlank handle whitespace-only strings', () {
      expect('   '.isBlank, isTrue);
      expect('   '.nullIfBlank, isNull);
    });

    test('isValidEmail accepts a typical email address', () {
      expect('hello@domodachi.app'.isValidEmail, isTrue);
      expect('not-an-email'.isValidEmail, isFalse);
    });

    test('validateRequired and validateMinLength return custom messages', () {
      expect(''.validateRequired(message: 'required'), 'required');
      expect('a'.validateMinLength(2, message: 'too short'), 'too short');
      expect('ab'.validateMinLength(2, message: 'too short'), isNull);
    });
  });
}
