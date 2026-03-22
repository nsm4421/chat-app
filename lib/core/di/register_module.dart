import 'package:domodachi/core/local_storage/hive_initializer.dart';
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;

  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @preResolve
  Future<HiveInterface> get hive => HiveInitializer.initialize();
}
