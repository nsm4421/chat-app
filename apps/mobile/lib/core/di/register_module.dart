import 'package:app_ui/app_ui.dart';
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:infra_hive/infra_hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;

  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @lazySingleton
  ThemeModeCubit themeModeCubit(SharedPreferences sharedPreferences) =>
      ThemeModeCubit(sharedPreferences);

  @preResolve
  Future<HiveInterface> get hive => HiveInitializer.initialize();
}
