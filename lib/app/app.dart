import 'package:domodachi/app/router/app_router.dart';
import 'package:domodachi/app/theme/app_theme.dart';
import 'package:domodachi/app/theme/theme_mode_cubit.dart';
import 'package:domodachi/features/auth/presentation/cubit/session/auth_session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: GetIt.instance<AuthSessionCubit>()),
        BlocProvider.value(value: GetIt.instance<ThemeModeCubit>()),
      ],
      child: BlocBuilder<ThemeModeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'Domodachi',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            routerConfig: GetIt.instance<AppRoute>().routeConfig,
          );
        },
      ),
    );
  }
}
