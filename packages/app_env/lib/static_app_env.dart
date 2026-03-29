import 'base_app_env.dart';

final class StaticAppEnv implements AppEnv {
  const StaticAppEnv({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });

  @override
  final String supabaseUrl;

  @override
  final String supabaseAnonKey;
}
