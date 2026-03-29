import 'package:domodachi/app/router/app_route_path.dart';
import 'package:app_ui/app_ui.dart';
import 'package:feature_auth/domain/validation/auth_input_validator.dart';
import 'package:feature_auth/presentation/cubit/base/auth_request_state.dart';
import 'package:feature_auth/presentation/cubit/password_reset/password_reset_cubit.dart';
import 'package:domodachi/features/auth/presentation/widgets/auth_page_scaffold.dart';
import 'package:domodachi/features/auth/presentation/widgets/auth_request_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<PasswordResetCubit>(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<PasswordResetCubit>().sendResetEmail(_emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    return AuthRequestListener<PasswordResetCubit>(
      child: BlocBuilder<PasswordResetCubit, AuthRequestState>(
        builder: (context, state) {
          return AuthPageScaffold(
            title: '비밀번호 재설정',
            subtitle: '가입한 이메일로 재설정 링크를 보냅니다.',
            footer: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton(
                  onPressed: state.isLoading
                      ? null
                      : () => context.go(AppRoutePath.signIn),
                  child: const Text('로그인으로 돌아가기'),
                ),
                TextButton(
                  onPressed: state.isLoading
                      ? null
                      : () => context.go(AppRoutePath.auth),
                  child: const Text('취소'),
                ),
              ],
            ),
            children: [
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: '이메일'),
                  validator: AuthInputValidator.email,
                  onFieldSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(height: 20),
              DebouncedFilledButton(
                onPressed: state.isLoading ? null : _submit,
                child: Text(state.isLoading ? '전송 중...' : '재설정 메일 보내기'),
              ),
            ],
          );
        },
      ),
    );
  }
}
