import 'package:domodachi/features/auth/data/exception/auth_data_exception.dart';
import 'package:domodachi/features/auth/data/repository/auth_repository_error_handler.dart';
import 'package:domodachi/features/auth/domain/failure/auth_failure.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestAuthRepositoryErrorHandler with AuthRepositoryErrorHandler {}

void main() {
  group('AuthRepositoryErrorHandler', () {
    final handler = _TestAuthRepositoryErrorHandler();

    test('maps known auth exceptions to localized messages', () async {
      await expectLater(
        () => handler.guardAuthRequest<void>(
          () async =>
              throw const AuthDataException('Invalid login credentials'),
          fallbackMessage: 'fallback',
        ),
        throwsA(
          isA<AuthFailure>().having(
            (error) => error.message,
            'message',
            '이메일 또는 비밀번호를 확인해 주세요.',
          ),
        ),
      );
    });

    test('uses fallback message for unknown exceptions', () async {
      await expectLater(
        () => handler.guardAuthRequest<void>(
          () async => throw Exception('boom'),
          fallbackMessage: 'fallback',
        ),
        throwsA(
          isA<AuthFailure>().having(
            (error) => error.message,
            'message',
            'fallback',
          ),
        ),
      );
    });
  });
}
