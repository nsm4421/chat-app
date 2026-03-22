import 'package:domodachi/app/router/app_route_path.dart';
import 'package:domodachi/core/extensions/num_extension.dart';
import 'package:domodachi/core/extensions/string_extension.dart';
import 'package:domodachi/core/widgets/debounce/debounced_buttons.dart';
import 'package:domodachi/features/auth/domain/validation/auth_input_validator.dart';
import 'package:domodachi/features/auth/presentation/cubit/base/auth_request_state.dart';
import 'package:domodachi/features/auth/presentation/cubit/sign_up/sign_up_cubit.dart';
import 'package:domodachi/features/auth/presentation/widgets/auth_page_scaffold.dart';
import 'package:domodachi/features/auth/presentation/widgets/auth_password_field.dart';
import 'package:domodachi/features/auth/presentation/widgets/auth_request_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<SignUpCubit>(),
      child: const _SignUpView(),
    );
  }
}

class _SignUpView extends StatefulWidget {
  const _SignUpView();

  @override
  State<_SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<_SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<SignUpCubit>().signUp(
      email: _emailController.text.trimmed,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthRequestListener<SignUpCubit>(
      child: BlocBuilder<SignUpCubit, AuthRequestState>(
        builder: (context, state) {
          return AuthPageScaffold(
            title: '회원가입',
            subtitle: '이메일과 비밀번호로 계정을 만들고 바로 시작하세요.',
            footer: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton(
                  onPressed: state.isLoading
                      ? null
                      : () => context.go(AppRoutePath.signIn),
                  child: const Text('이미 계정이 있어요'),
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
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.newUsername],
                      decoration: const InputDecoration(labelText: '이메일'),
                      validator: AuthInputValidator.email,
                    ),
                    12.v,
                    AuthPasswordField(
                      controller: _passwordController,
                      label: '비밀번호',
                      autofillHints: const [AutofillHints.newPassword],
                      validator: AuthInputValidator.password,
                    ),
                    12.v,
                    AuthPasswordField(
                      controller: _confirmPasswordController,
                      label: '비밀번호 확인',
                      validator: (value) => AuthInputValidator.confirmPassword(
                        value: value,
                        password: _passwordController.text,
                      ),
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ],
                ),
              ),
              20.v,
              DebouncedFilledButton(
                onPressed: state.isLoading ? null : _submit,
                child: Text(state.isLoading ? '가입 중...' : '가입하고 시작하기'),
              ),
            ],
          );
        },
      ),
    );
  }
}
