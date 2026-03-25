import 'package:domodachi/features/auth/data/exception/auth_data_exception.dart';
import 'package:domodachi/features/auth/data/model/auth_user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

mixin class SupabaseAuthDataSourceHandler {
  Future<T> guardAuthRequest<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthDataException {
      rethrow;
    } on AuthException catch (error) {
      throw AuthDataException(error.message);
    } on PostgrestException catch (error) {
      throw AuthDataException(error.message);
    }
  }

  Future<T> guardDeleteAccountRequest<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthDataException {
      rethrow;
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

  AuthUserModel? toAuthUserModel(User? user) {
    if (user == null) {
      return null;
    }

    final metadata = user.userMetadata ?? <String, dynamic>{};

    return AuthUserModel(
      id: user.id,
      email: user.email,
      username: (metadata['username'] as String?)?.trim(),
      avatarUrl: (metadata['avatar_url'] as String?)?.trim(),
      emailVerified: user.emailConfirmedAt != null,
      profileCompleted: metadata['profile_completed'] == true,
    );
  }

  Future<Session> getDeleteAccountSession(SupabaseClient client) async {
    final currentSession = client.auth.currentSession;
    if (currentSession == null) {
      throw const AuthDataException('로그인이 만료되어 탈퇴할 수 없어요. 다시 로그인해 주세요.');
    }

    if (!currentSession.isExpired) {
      return currentSession;
    }

    try {
      final refreshedSession = (await client.auth.refreshSession()).session;
      if (refreshedSession == null) {
        throw const AuthDataException('로그인이 만료되어 탈퇴할 수 없어요. 다시 로그인해 주세요.');
      }
      return refreshedSession;
    } on AuthException {
      throw const AuthDataException('로그인이 만료되어 탈퇴할 수 없어요. 다시 로그인해 주세요.');
    }
  }
}
