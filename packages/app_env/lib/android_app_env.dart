import 'package:envied/envied.dart';

import 'base_app_env.dart';
import 'static_app_env.dart';

part 'android_app_env.g.dart';

@Envied(path: '.env.android.local', obfuscate: true)
abstract final class AndroidAppEnv {
  @EnviedField(varName: 'SUPABASE_URL')
  static final String _supabaseUrl = _AndroidAppEnv._supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static final String _supabaseAnonKey = _AndroidAppEnv._supabaseAnonKey;

  static AppEnv get current => StaticAppEnv(
    supabaseUrl: _supabaseUrl,
    supabaseAnonKey: _supabaseAnonKey,
  );
}
