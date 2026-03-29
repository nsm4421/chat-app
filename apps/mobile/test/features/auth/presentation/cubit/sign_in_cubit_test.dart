import 'package:feature_auth/domain/failure/auth_failure.dart';
import 'package:feature_auth/domain/use_case/auth_use_cases.dart';
import 'package:feature_auth/presentation/cubit/base/auth_request_state.dart';
import 'package:feature_auth/presentation/cubit/sign_in/sign_in_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  group('SignInCubit', () {
    test('emits loading and success on sign in success', () async {
      final repository = FakeAuthRepository();
      final cubit = SignInCubit(AuthUseCases(repository));

      expectLater(
        cubit.stream,
        emitsInOrder([
          const AuthRequestState.loading(),
          const AuthRequestState.success(),
        ]),
      );

      await cubit.signIn(
        email: '  hello@domodachi.app  ',
        password: 'password1234',
      );

      expect(repository.signInCallCount, 1);
      expect(repository.lastSignInEmail, 'hello@domodachi.app');
      expect(repository.lastSignInPassword, 'password1234');

      await cubit.close();
    });

    test('emits loading and error on sign in failure', () async {
      final repository = FakeAuthRepository(
        signInHandler: ({required email, required password}) async {
          throw const AuthFailure('로그인에 실패했습니다.');
        },
      );
      final cubit = SignInCubit(AuthUseCases(repository));

      expectLater(
        cubit.stream,
        emitsInOrder([
          const AuthRequestState.loading(),
          const AuthRequestState.error('로그인에 실패했습니다.'),
        ]),
      );

      await cubit.signIn(
        email: 'hello@domodachi.app',
        password: 'password1234',
      );

      expect(repository.signInCallCount, 1);

      await cubit.close();
    });
  });
}
