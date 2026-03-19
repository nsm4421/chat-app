import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:domodachi/features/auth/domain/entity/auth_user.dart';

part 'auth_session_state.freezed.dart';

@freezed
sealed class AuthSessionState with _$AuthSessionState {
  const factory AuthSessionState.unknown() = _Unknown;

  const factory AuthSessionState.unauthenticated() = _Unauthenticated;

  const factory AuthSessionState.profileIncomplete(AuthUser user) =
      _ProfileIncomplete;

  const factory AuthSessionState.authenticated(AuthUser user) = _Authenticated;
}
