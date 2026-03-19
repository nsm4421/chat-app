import 'package:domodachi/app/theme/theme_mode_toggle_button.dart';
import 'package:domodachi/features/auth/presentation/cubit/account/delete_account_cubit.dart';
import 'package:domodachi/features/auth/presentation/widgets/auth_request_listener.dart';
import 'package:domodachi/features/settings/widgets/settings_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<DeleteAccountCubit>(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return AuthRequestListener<DeleteAccountCubit>(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          actions: const [ThemeModeToggleButton()],
        ),
        body: const SettingsContent(),
      ),
    );
  }
}
