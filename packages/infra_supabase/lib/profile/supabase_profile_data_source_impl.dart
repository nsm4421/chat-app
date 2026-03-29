import 'dart:typed_data';

import 'package:feature_profile/data/data_source/profile_data_source.dart';
import 'package:feature_profile/data/exception/profile_data_exception.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase/supabase.dart';

@LazySingleton(as: ProfileDataSource)
class SupabaseProfileDataSourceImpl implements ProfileDataSource {
  SupabaseProfileDataSourceImpl(this._client);

  final SupabaseClient _client;
  static const _avatarBucket = 'avatars';

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
    return _guardProfileRequest(() async {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw const ProfileDataException('로그인이 필요해요. 다시 시도해 주세요.');
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
    return _guardProfileRequest(() async {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw const ProfileDataException('로그인이 필요해요. 다시 시도해 주세요.');
      }

      final normalizedUsername = username.trim();
      final isAvailable = await isUsernameAvailable(normalizedUsername);
      if (!isAvailable) {
        throw const ProfileDataException('이미 사용 중인 아이디예요. 다른 아이디를 입력해 주세요.');
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
          throw const ProfileDataException('이미 사용 중인 아이디예요. 다른 아이디를 입력해 주세요.');
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

  Future<T> _guardProfileRequest<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ProfileDataException {
      rethrow;
    } on AuthException catch (error) {
      throw ProfileDataException(error.message);
    } on PostgrestException catch (error) {
      throw ProfileDataException(error.message);
    }
  }
}
