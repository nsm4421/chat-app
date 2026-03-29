import 'package:app_ui/app_ui.dart';
import 'package:feature_auth/presentation/cubit/account/delete_account_cubit.dart';
import 'package:feature_auth/presentation/cubit/base/auth_request_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DeleteAccountButton extends StatelessWidget {
  const DeleteAccountButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeleteAccountCubit, AuthRequestState>(
      builder: (context, state) {
        return DebouncedFilledTonalButton(
          onPressed: state.isLoading
              ? null
              : () => _showDeleteAccountDialog(context),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
          ),
          child: Text(state.isLoading ? '탈퇴 처리 중...' : '계정 탈퇴'),
        );
      },
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('계정을 삭제할까요?'),
          content: const Text('탈퇴하면 프로필과 로그인 정보가 함께 삭제되고 복구할 수 없어요.'),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => dialogContext.pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
                foregroundColor: Theme.of(dialogContext).colorScheme.onError,
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await context.read<DeleteAccountCubit>().deleteAccount();
  }
}
