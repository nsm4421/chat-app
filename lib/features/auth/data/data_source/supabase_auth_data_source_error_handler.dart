import 'package:domodachi/features/auth/data/exception/auth_data_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

mixin class SupabaseAuthDataSourceErrorHandler {
  Future<T> guardDeleteAccountRequest<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthException catch (error) {
      throw AuthDataException(error.message);
    } catch (error) {
      throw AuthDataException(mapDeleteAccountError(error));
    }
  }

  String mapDeleteAccountError(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('401') ||
        message.contains('unauthorized') ||
        message.contains('jwt')) {
      return '로그인이 만료되어 탈퇴할 수 없어요. 다시 로그인해 주세요.';
    }

    return '계정을 삭제하지 못했어요. 잠시 후 다시 시도해 주세요.';
  }
}
