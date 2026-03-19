import 'package:domodachi/features/auth/domain/use_case/auth_use_cases.dart';
import 'package:domodachi/features/auth/presentation/cubit/base/auth_request_state.dart';
import 'package:domodachi/features/auth/presentation/cubit/sign_up/sign_up_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  group('SignUpCubit', () {
    test('emits success when sign up succeeds', () async {
      final repository = FakeAuthRepository();
      final cubit = SignUpCubit(AuthUseCases(repository));

      expectLater(
        cubit.stream,
        emitsInOrder([
          const AuthRequestState.loading(),
          const AuthRequestState.success('회원가입이 완료되었어요.'),
        ]),
      );

      await cubit.signUp(
        email: 'hello@domodachi.app',
        password: 'password1234',
      );

      await cubit.close();
    });
  });
}
