import 'package:domodachi/app/router/app_route_path.dart';
import 'package:domodachi/features/auth/presentation/widgets/auth_page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthLandingPage extends StatelessWidget {
  const AuthLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      title: '코인왕 시작하기',
      subtitle: '가상 자산으로 과거 시세를 공략할 계정을 준비하세요.',
      footer: TextButton(
        onPressed: () => context.go(AppRoutePath.forgotPassword),
        child: const Text('비밀번호를 잊어버렸어요'),
      ),
      children: [
        FilledButton(
          onPressed: () => context.go(AppRoutePath.signIn),
          child: const Text('이메일로 로그인'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => context.go(AppRoutePath.signUp),
          child: const Text('새 계정 만들기'),
        ),
      ],
    );
  }
}
