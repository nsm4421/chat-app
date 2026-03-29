import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';
import 'package:feature_auth/presentation/cubit/base/auth_request_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthRequestCubit extends Cubit<AuthRequestState> {
  AuthRequestCubit() : super(const AuthRequestState.idle());

  @protected
  Future<void> run(
    Future<void> Function() action, {
    String? successMessage,
  }) async {
    emit(const AuthRequestState.loading());

    try {
      await action();
      emit(AuthRequestState.success(successMessage));
    } on Failure catch (error) {
      emit(AuthRequestState.error(error.message));
    }
  }
}
