import 'package:domodachi/core/error/failure.dart';
import 'package:domodachi/core/extensions/num_extension.dart';
import 'package:domodachi/core/extensions/string_extension.dart';
import 'package:domodachi/features/auth/domain/validation/auth_input_validator.dart';
import 'package:domodachi/features/auth/presentation/cubit/base/auth_request_state.dart';
import 'package:domodachi/features/auth/presentation/cubit/profile_setup/profile_setup_cubit.dart';
import 'package:domodachi/features/auth/presentation/cubit/session/auth_session_cubit.dart';
import 'package:domodachi/features/auth/presentation/cubit/session/auth_session_state.dart';
import 'package:domodachi/features/auth/presentation/widgets/auth_page_scaffold.dart';
import 'package:domodachi/features/auth/presentation/widgets/auth_request_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class ProfileSetupPage extends StatelessWidget {
  const ProfileSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<ProfileSetupCubit>(),
      child: const _ProfileSetupView(),
    );
  }
}

class _ProfileSetupView extends StatefulWidget {
  const _ProfileSetupView();

  @override
  State<_ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends State<_ProfileSetupView> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  var _isRestarting = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<ProfileSetupCubit>().submitProfile(
      _displayNameController.text.trimmed,
    );
  }

  Future<void> _restartWithAnotherEmail() async {
    setState(() => _isRestarting = true);

    try {
      await context.read<AuthSessionCubit>().signOut();
    } on Failure catch (error) {
      if (!mounted) {
        return;
      }

      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() => _isRestarting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthRequestListener<ProfileSetupCubit>(
      onSuccess: () => context.read<AuthSessionCubit>().refresh(),
      child: BlocBuilder<AuthSessionCubit, AuthSessionState>(
        builder: (context, sessionState) {
          final email = sessionState.maybeWhen(
            profileIncomplete: (user) => user.email ?? '',
            authenticated: (user) => user.email ?? '',
            orElse: () => '',
          );

          return AuthPageScaffold(
            title: '프로필 설정',
            subtitle: email.isEmpty
                ? '서비스 이용을 시작하기 전에 표시 이름을 정해 주세요.'
                : '$email 계정에 표시 이름을 저장합니다.',
            footer: TextButton(
              onPressed: _isRestarting ? null : _restartWithAnotherEmail,
              child: Text(_isRestarting ? '이동 중...' : '다른 이메일로 다시 시작'),
            ),
            children: [
              BlocBuilder<ProfileSetupCubit, AuthRequestState>(
                builder: (context, requestState) {
                  return Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _displayNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(labelText: '표시 이름'),
                          validator: AuthInputValidator.displayName,
                          onFieldSubmitted: (_) => _submit(),
                        ),
                      ),
                      20.v,
                      FilledButton(
                        onPressed: requestState.isLoading || _isRestarting
                            ? null
                            : _submit,
                        child: Text(
                          requestState.isLoading ? '저장 중...' : '계속하기',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
