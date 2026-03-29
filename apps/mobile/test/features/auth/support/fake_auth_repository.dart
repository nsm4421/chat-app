import 'dart:async';

import 'package:feature_auth/domain/entity/auth_user.dart';
import 'package:feature_auth/domain/repository/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    AuthUser? currentUser,
    Stream<AuthUser?>? authStateChanges,
    bool Function(AuthUser user)? isProfileComplete,
    Future<void> Function({required String email, required String password})?
    signInHandler,
    Future<void> Function({required String email, required String password})?
    signUpHandler,
    Future<void> Function()? signOutHandler,
    Future<void> Function()? deleteAccountHandler,
    Future<void> Function(String email)? sendPasswordResetEmailHandler,
  }) : _currentUser = currentUser,
       _authStateChanges = authStateChanges ?? const Stream.empty(),
       _isProfileComplete =
           isProfileComplete ?? ((user) => user.isProfileComplete),
       _signInHandler = signInHandler,
       _signUpHandler = signUpHandler,
       _signOutHandler = signOutHandler,
       _deleteAccountHandler = deleteAccountHandler,
       _sendPasswordResetEmailHandler = sendPasswordResetEmailHandler;

  AuthUser? _currentUser;
  final Stream<AuthUser?> _authStateChanges;
  final bool Function(AuthUser user) _isProfileComplete;
  final Future<void> Function({
    required String email,
    required String password,
  })?
  _signInHandler;
  final Future<void> Function({
    required String email,
    required String password,
  })?
  _signUpHandler;
  final Future<void> Function()? _signOutHandler;
  final Future<void> Function()? _deleteAccountHandler;
  final Future<void> Function(String email)? _sendPasswordResetEmailHandler;

  int signInCallCount = 0;
  String? lastSignInEmail;
  String? lastSignInPassword;

  set currentUserValue(AuthUser? user) => _currentUser = user;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> get authStateChanges => _authStateChanges;

  @override
  bool isProfileComplete(AuthUser user) => _isProfileComplete(user);

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCallCount += 1;
    lastSignInEmail = email;
    lastSignInPassword = password;

    await _signInHandler?.call(email: email, password: password);
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    await _signUpHandler?.call(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _signOutHandler?.call();
  }

  @override
  Future<void> deleteAccount() async {
    await _deleteAccountHandler?.call();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _sendPasswordResetEmailHandler?.call(email);
  }
}
