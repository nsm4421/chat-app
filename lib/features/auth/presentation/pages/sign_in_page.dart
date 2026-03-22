import 'package:domodachi/app/router/app_route_path.dart';
import 'package:domodachi/core/extensions/num_extension.dart';
import 'package:domodachi/core/extensions/string_extension.dart';
import 'package:domodachi/core/widgets/debounce/debounced_buttons.dart';
import 'package:domodachi/features/auth/domain/validation/auth_input_validator.dart';
import 'package:domodachi/features/auth/presentation/cubit/base/auth_request_state.dart';
import 'package:domodachi/features/auth/presentation/cubit/sign_in/sign_in_cubit.dart';
import 'package:domodachi/features/auth/presentation/widgets/auth_page_scaffold.dart';
import 'package:domodachi/features/auth/presentation/widgets/auth_password_field.dart';
import 'package:domodachi/features/auth/presentation/widgets/auth_request_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<SignInCubit>(),
      child: const _SignInView(),
    );
  }
}

class _SignInView extends StatefulWidget {
  const _SignInView();

  @override
  State<_SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<_SignInView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<SignInCubit>().signIn(
      email: _emailController.text.trimmed,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthRequestListener<SignInCubit>(
      child: BlocBuilder<SignInCubit, AuthRequestState>(
        builder: (context, state) {
          return AuthPageScaffold(
            title: '로그인',
            subtitle: '가입한 이메일로 다시 들어오세요.',
            footer: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton(
                  onPressed: state.isLoading
                      ? null
                      : () => context.go(AppRoutePath.signUp),
                  child: const Text('계정이 없어요'),
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
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(labelText: '이메일'),
                      validator: AuthInputValidator.email,
                    ),
                    12.v,
                    AuthPasswordField(
                      controller: _passwordController,
                      label: '비밀번호',
                      autofillHints: const [AutofillHints.password],
                      validator: AuthInputValidator.password,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ],
                ),
              ),
              20.v,
              DebouncedFilledButton(
                onPressed: state.isLoading ? null : _submit,
                child: Text(state.isLoading ? '로그인 중...' : '로그인'),
              ),
            ],
          );
        },
      ),
    );
  }
}
