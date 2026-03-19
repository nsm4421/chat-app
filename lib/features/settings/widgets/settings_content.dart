import 'package:domodachi/core/extensions/num_extension.dart';
import 'package:domodachi/features/auth/presentation/widgets/auth_sign_out_button.dart';
import 'package:domodachi/app/theme/theme_mode_toggle_button.dart';
import 'package:domodachi/features/settings/widgets/delete_account_button.dart';
import 'package:flutter/material.dart';

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
        if (showInlineToggle) ...[
          12.v,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('계정', style: theme.textTheme.titleLarge),
                8.v,
                Text(
                  '로그아웃 또는 계정 탈퇴를 진행할 수 있어요.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                20.v,
                const AuthSignOutButton(),
                12.v,
                const DeleteAccountButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
