import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class ThemeModeCubit extends Cubit<ThemeMode> {
  ThemeModeCubit(this._sharedPreferences) : super(ThemeMode.system);

  static const _themeModeKey = 'theme_mode';

  final SharedPreferences _sharedPreferences;

  Future<void> init() async {
    emit(_readStoredThemeMode());
  }

  Future<void> toggle() async {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _sharedPreferences.setString(_themeModeKey, nextMode.name);
    emit(nextMode);
  }

  ThemeMode _readStoredThemeMode() {
    return switch (_sharedPreferences.getString(_themeModeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.system,
    };
  }
}
