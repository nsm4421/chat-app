import 'package:domodachi/features/auth/data/data_source/supabase_auth_data_source_handler.dart';
import 'package:domodachi/features/auth/data/exception/auth_data_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _TestSupabaseAuthDataSourceHandler with SupabaseAuthDataSourceHandler {}

void main() {
  group('SupabaseAuthDataSourceHandler', () {
    final handler = _TestSupabaseAuthDataSourceHandler();

    test('maps auth exceptions to auth data exception messages', () async {
      await expectLater(
        () => handler.guardDeleteAccountRequest<void>(
          () async => throw const AuthException('Session expired'),
        ),
        throwsA(
          isA<AuthDataException>().having(
            (error) => error.message,
            'message',
            'Session expired',
          ),
        ),
      );
    });

    test(
      'maps unauthorized delete account errors to relogin message',
      () async {
        await expectLater(
          () => handler.guardDeleteAccountRequest<void>(
            () async => throw Exception('401 Unauthorized'),
          ),
          throwsA(
            isA<AuthDataException>().having(
              (error) => error.message,
              'message',
              '로그인이 만료되어 탈퇴할 수 없어요. 다시 로그인해 주세요.',
            ),
          ),
        );
      },
    );

    test('passes through auth data exception messages', () async {
      await expectLater(
        () => handler.guardDeleteAccountRequest<void>(
          () async => throw const AuthDataException('직접 지정한 메시지'),
        ),
        throwsA(
          isA<AuthDataException>().having(
            (error) => error.message,
            'message',
            '직접 지정한 메시지',
          ),
        ),
      );
    });

    test('uses fallback message for unknown delete account errors', () async {
      await expectLater(
        () => handler.guardDeleteAccountRequest<void>(
          () async => throw Exception('boom'),
        ),
        throwsA(
          isA<AuthDataException>().having(
            (error) => error.message,
            'message',
            '계정을 삭제하지 못했어요. 잠시 후 다시 시도해 주세요.',
          ),
        ),
      );
    });
  });
}
