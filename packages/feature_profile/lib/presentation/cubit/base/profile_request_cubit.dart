import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:feature_profile/presentation/cubit/base/profile_request_state.dart';
import 'package:shared/shared.dart';

abstract class ProfileRequestCubit extends Cubit<ProfileRequestState> {
  ProfileRequestCubit() : super(const ProfileRequestState.idle());

  @protected
  Future<void> run(
    Future<void> Function() action, {
    String? successMessage,
  }) async {
    emit(const ProfileRequestState.loading());

    try {
      await action();
      emit(ProfileRequestState.success(successMessage));
    } on Failure catch (error) {
      emit(ProfileRequestState.error(error.message));
    }
  }
}
