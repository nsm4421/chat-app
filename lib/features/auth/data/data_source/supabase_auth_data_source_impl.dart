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
  Future<void> completeProfile({required String displayName}) {
    return guardAuthRequest(() async {
      await _client.auth.updateUser(
        UserAttributes(
          data: <String, dynamic>{
            'display_name': displayName,
            'profile_completed': true,
          },
        ),
      );
    });
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
