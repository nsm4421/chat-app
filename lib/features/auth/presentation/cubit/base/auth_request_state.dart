import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_request_state.freezed.dart';

@freezed
sealed class AuthRequestState with _$AuthRequestState {
  const factory AuthRequestState.idle() = _Idle;

  const factory AuthRequestState.loading() = _Loading;

  const factory AuthRequestState.success([String? message]) = _Success;

  const factory AuthRequestState.error(String message) = _Error;
}

extension AuthRequestStateX on AuthRequestState {
  bool get isLoading => maybeWhen(loading: () => true, orElse: () => false);
}
