import 'package:feature_auth/presentation/cubit/base/auth_request_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthRequestListener<C extends StateStreamable<AuthRequestState>>
    extends StatelessWidget {
  const AuthRequestListener({super.key, required this.child, this.onSuccess});

  final Widget child;
  final VoidCallback? onSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocListener<C, AuthRequestState>(
      listener: (context, state) {
        state.whenOrNull(
          success: (message) {
            if (message != null && message.isNotEmpty) {
              final messenger = ScaffoldMessenger.of(context);
              messenger.hideCurrentSnackBar();
              messenger.showSnackBar(SnackBar(content: Text(message)));
            }
            onSuccess?.call();
          },
          error: (message) {
            final messenger = ScaffoldMessenger.of(context);
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(SnackBar(content: Text(message)));
          },
        );
      },
      child: child,
    );
  }
}
