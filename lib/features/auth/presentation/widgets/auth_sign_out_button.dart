import 'package:domodachi/core/error/failure.dart';
import 'package:domodachi/core/widgets/debounce/debounced_buttons.dart';
import 'package:domodachi/features/auth/presentation/cubit/session/auth_session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthSignOutButton extends StatefulWidget {
  const AuthSignOutButton({super.key});

  @override
  State<AuthSignOutButton> createState() => _AuthSignOutButtonState();
}

class _AuthSignOutButtonState extends State<AuthSignOutButton> {
  var _isSubmitting = false;

  Future<void> _handlePressed() async {
    setState(() => _isSubmitting = true);

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
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DebouncedOutlinedButton(
      onPressed: _isSubmitting ? null : _handlePressed,
      child: Text(_isSubmitting ? 'Signing out...' : 'Sign out'),
    );
  }
}
