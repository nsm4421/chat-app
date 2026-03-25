import 'dart:typed_data';

import 'package:domodachi/features/auth/data/data_source/auth_data_source.dart';
import 'package:domodachi/features/auth/data/data_source/supabase_auth_data_source_handler.dart';
import 'package:domodachi/features/auth/data/exception/auth_data_exception.dart';
import 'package:domodachi/features/auth/data/model/auth_user_model.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: AuthDataSource)
class SupabaseAuthDataSourceImpl
    with SupabaseAuthDataSourceHandler
    implements AuthDataSource {
  SupabaseAuthDataSourceImpl(this._client);

  final SupabaseClient _client;
  static const _avatarBucket = 'avatars';

  @override
  AuthUserModel? get currentUser {
    return toAuthUserModel(_client.auth.currentUser);
  }

  @override
  Stream<AuthUserModel?> get authStateChanges => _client.auth.onAuthStateChange
      .map((state) => toAuthUserModel(state.session?.user));

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) {
    return guardAuthRequest(() async {
      await _client.auth.signInWithPassword(email: email, password: password);
      await _syncAccountStateAfterSignIn();
    });
  }

  @override
  Future<void> signUp({required String email, required String password}) {
    return guardAuthRequest(() async {
      await _client.auth.signUp(email: email, password: password);
    });
  }

  @override
  Future<void> signOut() {
    return guardAuthRequest(() => _client.auth.signOut());
  }

  @override
  Future<void> deleteAccount() {
    return guardDeleteAccountRequest(() async {
      final session = await getDeleteAccountSession(_client);

      final response = await _client.functions.invoke(
        'delete-account',
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] != true) {
        throw AuthDataException(
          (data['error'] as String?) ?? '계정을 삭제하지 못했어요. 잠시 후 다시 시도해 주세요.',
        );
      }

      await _client.auth.signOut(scope: SignOutScope.local);
    });
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return guardAuthRequest(() => _client.auth.resetPasswordForEmail(email));
  }

  @override
  Future<void> completeProfile({required String username}) {
    return _saveProfile(
      username: username,
      profileCompleted: true,
    );
  }

  @override
  Future<void> updateProfile({
    required String username,
    Uint8List? avatarBytes,
    String? avatarFileExtension,
  }) {
    return _saveProfile(
      username: username,
      avatarBytes: avatarBytes,
      avatarFileExtension: avatarFileExtension,
      profileCompleted: true,
    );
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    return guardAuthRequest(() async {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw const AuthDataException('로그인이 필요해요. 다시 시도해 주세요.');
      }

      final response = await _client
          .from('profiles')
          .select('id')
          .eq('username', username.trim())
          .neq('id', currentUser.id)
          .limit(1)
          .maybeSingle();

      return response == null;
    });
  }

  Future<void> _saveProfile({
    required String username,
    Uint8List? avatarBytes,
    String? avatarFileExtension,
    required bool profileCompleted,
  }) {
    return guardAuthRequest(() async {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw const AuthDataException('로그인이 필요해요. 다시 시도해 주세요.');
      }

      final normalizedUsername = username.trim();
      final isAvailable = await isUsernameAvailable(normalizedUsername);
      if (!isAvailable) {
        throw const AuthDataException('이미 사용 중인 아이디예요. 다른 아이디를 입력해 주세요.');
      }

      final avatarUrl = avatarBytes == null
          ? (currentUser.userMetadata?['avatar_url'] as String?)
          : await _uploadAvatar(
              userId: currentUser.id,
              avatarBytes: avatarBytes,
              avatarFileExtension: avatarFileExtension,
            );

      try {
        await _client.from('profiles').upsert({
          'id': currentUser.id,
          'email': currentUser.email,
          'username': normalizedUsername,
          'avatar_url': avatarUrl,
          'onboarding_completed': profileCompleted,
        });
      } on PostgrestException catch (error) {
        if (error.code == '23505') {
          throw const AuthDataException('이미 사용 중인 아이디예요. 다른 아이디를 입력해 주세요.');
        }
        rethrow;
      }

      await _client.auth.updateUser(
        UserAttributes(
          data: <String, dynamic>{
            'username': normalizedUsername,
            'avatar_url': avatarUrl,
            'profile_completed': profileCompleted,
          },
        ),
      );
    });
  }

  Future<String> _uploadAvatar({
    required String userId,
    required Uint8List avatarBytes,
    String? avatarFileExtension,
  }) async {
    final extension = _normalizeAvatarExtension(avatarFileExtension);
    final path = '$userId/avatar.$extension';
    final cacheBust = DateTime.now().millisecondsSinceEpoch;

    await _client.storage.from(_avatarBucket).uploadBinary(
          path,
          avatarBytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: _contentTypeForExtension(extension),
          ),
        );

    return '${_client.storage.from(_avatarBucket).getPublicUrl(path)}?v=$cacheBust';
  }

  String _normalizeAvatarExtension(String? extension) {
    final normalized = (extension ?? '').trim().toLowerCase();
    if (normalized == 'png' ||
        normalized == 'webp' ||
        normalized == 'gif' ||
        normalized == 'heic') {
      return normalized;
    }
    return 'jpg';
  }

  String _contentTypeForExtension(String extension) {
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      'heic' => 'image/heic',
      _ => 'image/jpeg',
    };
  }

  Future<void> _syncAccountStateAfterSignIn() async {
    try {
      await _client.rpc('touch_current_user_account_state');
    } catch (_) {
      // last_seen synchronization should not turn a successful sign-in
      // into a user-facing auth failure.
    }
  }
}
