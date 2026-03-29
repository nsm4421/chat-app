import 'package:domodachi/core/extensions/num_extension.dart';
import 'package:shared/shared.dart';
import 'package:app_ui/app_ui.dart';
import 'package:feature_auth/presentation/cubit/session/auth_session_cubit.dart';
import 'package:feature_auth/presentation/cubit/session/auth_session_state.dart';
import 'package:feature_profile/domain/validation/profile_input_validator.dart';
import 'package:feature_profile/presentation/cubit/base/profile_request_state.dart';
import 'package:feature_profile/presentation/cubit/profile_setup/profile_setup_cubit.dart';
import 'package:domodachi/features/auth/presentation/widgets/auth_page_scaffold.dart';
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
  final _usernameController = TextEditingController();
  var _isRestarting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<ProfileSetupCubit>().submitProfile(
      _usernameController.text.trimmed,
    );
  }

  String? _validateUsername(String? value) {
    final username = (value ?? '').trim();
    if (username.isEmpty) {
      return '아이디를 입력해 주세요.';
    }
    return ProfileInputValidator.username(username);
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
    return BlocListener<ProfileSetupCubit, ProfileRequestState>(
      listener: (context, requestState) {
        requestState.whenOrNull(
          success: (message) {
            if (message != null && message.isNotEmpty) {
              final messenger = ScaffoldMessenger.of(context);
              messenger.hideCurrentSnackBar();
              messenger.showSnackBar(SnackBar(content: Text(message)));
            }
            context.read<AuthSessionCubit>().refresh();
          },
          error: (message) {
            final messenger = ScaffoldMessenger.of(context);
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(SnackBar(content: Text(message)));
          },
        );
      },
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
                ? '서비스에서 사용할 고유 아이디를 정하면 바로 시작할 수 있어요.'
                : '$email 계정으로 사용할 고유 아이디를 먼저 정해 주세요.',
            footer: DebouncedTextButton(
              onPressed: _isRestarting ? null : _restartWithAnotherEmail,
              child: Text(_isRestarting ? '이동 중...' : '다른 이메일로 다시 시작'),
            ),
            children: [
              BlocBuilder<ProfileSetupCubit, ProfileRequestState>(
                builder: (context, requestState) {
                  final theme = Theme.of(context);
                  final colorScheme = theme.colorScheme;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                email.isEmpty ? '새 프로필 만들기' : email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            14.v,
                            Text(
                              '한 번 정한 아이디는 친구 검색과 프로필 구분에 쓰여요.',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            8.v,
                            Text(
                              '영문, 숫자, 밑줄을 조합해서 나를 잘 나타내는 이름으로 정해 보세요.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      20.v,
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _usernameController,
                          textCapitalization: TextCapitalization.none,
                          autocorrect: false,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: '아이디',
                            hintText: '예: domodachi_01',
                          ),
                          validator: _validateUsername,
                          onFieldSubmitted: (_) => _submit(),
                        ),
                      ),
                      12.v,
                      Text(
                        '중복되지 않는 아이디만 사용할 수 있어요.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      20.v,
                      DebouncedFilledButtonIcon(
                        onPressed:
                            requestState.isLoading ||
                                _isRestarting ||
                                _usernameController.text.trim().isEmpty
                            ? null
                            : _submit,
                        icon: Icon(
                          requestState.isLoading
                              ? Icons.hourglass_top_rounded
                              : Icons.arrow_forward_rounded,
                        ),
                        label: Text(
                          requestState.isLoading
                              ? '아이디 저장 중...'
                              : '아이디 저장하고 시작하기',
                        ),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
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
