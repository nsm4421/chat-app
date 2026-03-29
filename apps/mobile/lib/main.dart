import 'package:domodachi/app/app.dart';
import 'package:domodachi/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/env/app_env_selector.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final env = resolveAppEnv();

  await Supabase.initialize(url: env.supabaseUrl, anonKey: env.supabaseAnonKey);
  await configureDependencies();

  runApp(const MainApp());
}
