import 'package:domodachi/features/auth/data/data_source/auth_data_source.dart';
import 'package:domodachi/features/auth/data/data_source/supabase_auth_data_source_error_handler.dart';
import 'package:domodachi/features/auth/data/exception/auth_data_exception.dart';
import 'package:domodachi/features/auth/data/model/auth_user_model.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: AuthDataSource)
class SupabaseAuthDataSourceImpl
    with SupabaseAuthDataSourceErrorHandler
    implements AuthDataSource {
  SupabaseAuthDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  AuthUserModel? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }
    return _toAuthUserModel(user);
  }

  @override
  Stream<AuthUserModel?> get authStateChanges =>
      _client.auth.onAuthStateChange.map((state) {
        final user = state.session?.user;
        if (user == null) {
          return null;
        }
        return _toAuthUserModel(user);
      });

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _guard(() async {
      await _client.auth.signInWithPassword(email: email, password: password);
      await _syncAccountStateAfterSignIn();
    });
  }

  @override
  Future<void> signUp({required String email, required String password}) {
    return _guard(() async {
      await _client.auth.signUp(email: email, password: password);
    });
  }

  @override
  Future<void> signOut() {
    return _guard(() => _client.auth.signOut());
  }

  @override
  Future<void> deleteAccount() {
    return guardDeleteAccountRequest(() async {
      await _client.functions.invoke('delete-account');
      await _client.auth.signOut(scope: SignOutScope.local);
    });
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _guard(() => _client.auth.resetPasswordForEmail(email));
  }

  @override
  Future<void> completeProfile({required String displayName}) {
    return _guard(() async {
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

  AuthUserModel _toAuthUserModel(User user) {
    final metadata = user.userMetadata ?? <String, dynamic>{};

    return AuthUserModel(
      id: user.id,
      email: user.email,
      displayName: (metadata['display_name'] as String?)?.trim(),
      emailVerified: user.emailConfirmedAt != null,
      profileCompleted: metadata['profile_completed'] == true,
    );
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthException catch (error) {
      throw AuthDataException(error.message);
    }
  }
}
