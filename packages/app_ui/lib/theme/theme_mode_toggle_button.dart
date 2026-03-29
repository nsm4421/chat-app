import 'package:app_ui/theme/theme_mode_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeModeToggleButton extends StatelessWidget {
  const ThemeModeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeModeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkActive =
            themeMode == ThemeMode.dark ||
            (themeMode == ThemeMode.system &&
                Theme.of(context).brightness == Brightness.dark);

        return IconButton(
          onPressed: context.read<ThemeModeCubit>().toggle,
          tooltip: isDarkActive ? '라이트 모드로 전환' : '다크 모드로 전환',
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Icon(
              isDarkActive ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
              key: ValueKey(isDarkActive),
            ),
          ),
        );
      },
    );
  }
}
