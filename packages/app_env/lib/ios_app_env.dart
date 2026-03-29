import 'package:envied/envied.dart';

import 'base_app_env.dart';
import 'static_app_env.dart';

part 'ios_app_env.g.dart';

@Envied(path: '.env.ios.local', obfuscate: true)
abstract final class IosAppEnv {
  @EnviedField(varName: 'SUPABASE_URL')
  static final String _supabaseUrl = _IosAppEnv._supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static final String _supabaseAnonKey = _IosAppEnv._supabaseAnonKey;

  static AppEnv get current => StaticAppEnv(
    supabaseUrl: _supabaseUrl,
    supabaseAnonKey: _supabaseAnonKey,
  );
}
