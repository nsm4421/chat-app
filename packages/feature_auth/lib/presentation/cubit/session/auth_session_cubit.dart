import 'dart:async';

import 'package:feature_auth/domain/entity/auth_user.dart';
import 'package:feature_auth/domain/use_case/auth_use_cases.dart';
import 'package:feature_auth/presentation/cubit/session/auth_session_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AuthSessionCubit extends Cubit<AuthSessionState> {
  AuthSessionCubit(this._authUseCases)
    : super(const AuthSessionState.unknown()) {
    _subscription = _authUseCases.observeAuthStateChanges().listen(
      _emitForUser,
    );
    refresh();
  }

  final AuthUseCases _authUseCases;
  late final StreamSubscription<AuthUser?> _subscription;

  void refresh() {
    _emitForUser(_authUseCases.currentUser());
  }

  Future<void> signOut() {
    return _authUseCases.signOut();
  }

  Future<void> deleteAccount() {
    return _authUseCases.deleteAccount();
  }

  void _emitForUser(AuthUser? user) {
    emit(_resolveState(user));
  }

  AuthSessionState _resolveState(AuthUser? user) {
    if (user == null) {
      return const AuthSessionState.unauthenticated();
    }

    if (_authUseCases.isProfileComplete(user)) {
      return AuthSessionState.authenticated(user);
    }

    return AuthSessionState.profileIncomplete(user);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
