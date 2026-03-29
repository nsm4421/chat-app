import 'dart:async';

import 'package:feature_auth/domain/entity/auth_user.dart';
import 'package:feature_auth/domain/use_case/auth_use_cases.dart';
import 'package:feature_auth/presentation/cubit/session/auth_session_cubit.dart';
import 'package:feature_auth/presentation/cubit/session/auth_session_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  group('AuthSessionCubit', () {
    test('emits unauthenticated when current user is null', () async {
      final repository = FakeAuthRepository();
      final cubit = AuthSessionCubit(AuthUseCases(repository));

      expect(cubit.state, const AuthSessionState.unauthenticated());

      await cubit.close();
    });

    test('emits authenticated when current user profile is complete', () async {
      const user = AuthUser(
        id: 'user-1',
        email: 'hello@domodachi.app',
        username: 'domo',
        emailVerified: true,
        profileCompleted: true,
      );
      final repository = FakeAuthRepository(currentUser: user);
      final cubit = AuthSessionCubit(AuthUseCases(repository));

      expect(cubit.state, AuthSessionState.authenticated(user));

      await cubit.close();
    });

    test(
      'emits profileIncomplete when current user profile is incomplete',
      () async {
        const user = AuthUser(
          id: 'user-1',
          email: 'hello@domodachi.app',
          emailVerified: false,
        );
        final repository = FakeAuthRepository(currentUser: user);
        final cubit = AuthSessionCubit(AuthUseCases(repository));

        expect(cubit.state, AuthSessionState.profileIncomplete(user));

        await cubit.close();
      },
    );

    test('reacts to auth state stream changes', () async {
      const incompleteUser = AuthUser(
        id: 'user-1',
        email: 'hello@domodachi.app',
        username: 'domo',
        emailVerified: false,
        profileCompleted: false,
      );
      const completeUser = AuthUser(
        id: 'user-1',
        email: 'hello@domodachi.app',
        username: 'domo',
        emailVerified: true,
        profileCompleted: true,
      );
      final controller = StreamController<AuthUser?>();
      final repository = FakeAuthRepository(
        authStateChanges: controller.stream,
        isProfileComplete: (user) => user.isProfileComplete,
      );
      final cubit = AuthSessionCubit(AuthUseCases(repository));

      expectLater(
        cubit.stream,
        emitsInOrder([
          AuthSessionState.profileIncomplete(incompleteUser),
          AuthSessionState.authenticated(completeUser),
        ]),
      );

      controller.add(incompleteUser);
      controller.add(completeUser);

      await controller.close();
      await cubit.close();
    });
  });
}
