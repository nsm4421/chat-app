import 'package:domodachi/app/router/app_route_path.dart';
import 'package:domodachi/features/auth/presentation/widgets/auth_page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthLandingPage extends StatelessWidget {
  const AuthLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      title: 'Domodachi 시작하기',
      subtitle: '로그인하거나 새 계정을 만들어 친구 기반 경험을 시작하세요.',
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
