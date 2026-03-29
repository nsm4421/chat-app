import 'package:envied/envied.dart';

import 'base_app_env.dart';
import 'static_app_env.dart';

part 'web_app_env.g.dart';

@Envied(path: '.env.web.local', obfuscate: true)
abstract final class WebAppEnv {
  @EnviedField(varName: 'SUPABASE_URL')
  static final String _supabaseUrl = _WebAppEnv._supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static final String _supabaseAnonKey = _WebAppEnv._supabaseAnonKey;

  static AppEnv get current => StaticAppEnv(
    supabaseUrl: _supabaseUrl,
    supabaseAnonKey: _supabaseAnonKey,
  );
}
