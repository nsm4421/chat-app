import 'package:feature_auth/domain/use_case/auth_use_cases.dart';
import 'package:feature_auth/presentation/cubit/sign_in/sign_in_cubit.dart';
import 'package:domodachi/features/auth/presentation/pages/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  final getIt = GetIt.instance;

  setUp(() async {
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('SignInPage', () {
    testWidgets('shows validation messages and does not submit invalid form', (
      tester,
    ) async {
      final repository = FakeAuthRepository();
      getIt.registerFactory<SignInCubit>(
        () => SignInCubit(AuthUseCases(repository)),
      );

      await tester.pumpWidget(const MaterialApp(home: SignInPage()));

      await tester.tap(find.widgetWithText(FilledButton, '로그인'));
      await tester.pump();

      expect(find.text('이메일을 입력해 주세요.'), findsOneWidget);
      expect(find.text('비밀번호를 입력해 주세요.'), findsOneWidget);
      expect(repository.signInCallCount, 0);
    });

    testWidgets('submits trimmed email when form is valid', (tester) async {
      final repository = FakeAuthRepository();
      getIt.registerFactory<SignInCubit>(
        () => SignInCubit(AuthUseCases(repository)),
      );

      await tester.pumpWidget(const MaterialApp(home: SignInPage()));

      await tester.enterText(
        find.byType(TextFormField).first,
        '  hello@domodachi.app  ',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password1234');

      await tester.tap(find.widgetWithText(FilledButton, '로그인'));
      await tester.pump();

      expect(repository.signInCallCount, 1);
      expect(repository.lastSignInEmail, 'hello@domodachi.app');
      expect(repository.lastSignInPassword, 'password1234');
    });
  });
}
