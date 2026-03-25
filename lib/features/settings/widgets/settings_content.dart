import 'package:domodachi/app/router/app_route_path.dart';
import 'package:domodachi/core/extensions/num_extension.dart';
import 'package:domodachi/core/widgets/profile_avatar.dart';
import 'package:domodachi/features/auth/presentation/cubit/session/auth_session_cubit.dart';
import 'package:domodachi/features/auth/presentation/cubit/session/auth_session_state.dart';
import 'package:domodachi/features/auth/presentation/widgets/auth_sign_out_button.dart';
import 'package:domodachi/app/theme/theme_mode_toggle_button.dart';
import 'package:domodachi/features/settings/widgets/delete_account_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key, this.showInlineToggle = false});

  final bool showInlineToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        Text(
          '설정',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        8.v,
        Text(
          '계정과 앱 환경설정을 여기에서 관리할 수 있어요.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        24.v,
        Card(
          child: Padding(
            padding: 20.p,
            child: BlocBuilder<AuthSessionCubit, AuthSessionState>(
              builder: (context, state) {
                final user = state.maybeWhen(
                  authenticated: (user) => user,
                  profileIncomplete: (user) => user,
                  orElse: () => null,
                );
                final username = (user?.username ?? '').trim();
                final avatarUrl = user?.avatarUrl;
                final email = user?.email ?? '';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '계정 및 프로필',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    6.v,
                    Text(
                      '아이디 수정과 계정 관리를 한 곳에서 할 수 있어요.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    16.v,
                    ListTile(
                      onTap: () => context.push(AppRoutePath.editProfile),
                      contentPadding: EdgeInsets.zero,
                      leading: ProfileAvatar(
                        radius: 24,
                        username: username.isEmpty ? 'guest' : username,
                        imageUrl: avatarUrl,
                      ),
                      title: Text(
                        username.isEmpty ? '아이디를 설정해 주세요' : '@$username',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        email.isEmpty ? '프로필 정보를 수정할 수 있어요.' : email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                    ),
                    16.v,
                    const AuthSignOutButton(),
                    12.v,
                    const DeleteAccountButton(),
                  ],
                );
              },
            ),
          ),
        ),
        if (showInlineToggle) ...[
          16.v,
          Card(
            child: Padding(
              padding: 16.p,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('다크 모드', style: theme.textTheme.titleMedium),
                        4.v,
                        Text(
                          '라이트와 다크 테마를 바로 전환할 수 있어요.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const ThemeModeToggleButton(),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
