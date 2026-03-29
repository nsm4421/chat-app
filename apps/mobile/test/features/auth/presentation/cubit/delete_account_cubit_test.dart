import 'package:feature_auth/domain/failure/auth_failure.dart';
import 'package:feature_auth/domain/use_case/auth_use_cases.dart';
import 'package:feature_auth/presentation/cubit/account/delete_account_cubit.dart';
import 'package:feature_auth/presentation/cubit/base/auth_request_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  group('DeleteAccountCubit', () {
    test('emits loading and success on delete account success', () async {
      final repository = FakeAuthRepository();
      final cubit = DeleteAccountCubit(AuthUseCases(repository));

      expectLater(
        cubit.stream,
        emitsInOrder([
          const AuthRequestState.loading(),
          const AuthRequestState.success('계정이 삭제되었어요.'),
        ]),
      );

      await cubit.deleteAccount();
      await cubit.close();
    });

    test('emits loading and error on delete account failure', () async {
      final repository = FakeAuthRepository(
        deleteAccountHandler: () async {
          throw const AuthFailure('탈퇴에 실패했어요.');
        },
      );
      final cubit = DeleteAccountCubit(AuthUseCases(repository));

      expectLater(
        cubit.stream,
        emitsInOrder([
          const AuthRequestState.loading(),
          const AuthRequestState.error('탈퇴에 실패했어요.'),
        ]),
      );

      await cubit.deleteAccount();
      await cubit.close();
    });
  });
}
