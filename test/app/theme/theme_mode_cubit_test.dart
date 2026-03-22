import 'package:domodachi/app/theme/theme_mode_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeModeCubit', () {
    test('loads saved theme mode on init', () async {
      SharedPreferences.setMockInitialValues({
        'theme_mode': ThemeMode.dark.name,
      });
      final preferences = await SharedPreferences.getInstance();
      final cubit = ThemeModeCubit(preferences);

      await cubit.init();

      expect(cubit.state, ThemeMode.dark);
      await cubit.close();
    });

    test('persists toggled theme mode', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final cubit = ThemeModeCubit(preferences);

      await cubit.toggle();

      expect(cubit.state, ThemeMode.dark);
      expect(preferences.getString('theme_mode'), ThemeMode.dark.name);
      await cubit.close();
    });
  });
}
