import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_request_state.freezed.dart';

@freezed
sealed class ProfileRequestState with _$ProfileRequestState {
  const factory ProfileRequestState.idle() = _Idle;

  const factory ProfileRequestState.loading() = _Loading;

  const factory ProfileRequestState.success([String? message]) = _Success;

  const factory ProfileRequestState.error(String message) = _Error;
}

extension ProfileRequestStateX on ProfileRequestState {
  bool get isLoading => maybeWhen(loading: () => true, orElse: () => false);
}
