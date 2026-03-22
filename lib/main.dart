import 'package:domodachi/app/app.dart';
import 'package:domodachi/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/env/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
  await configureDependencies();

  runApp(const MainApp());
}
