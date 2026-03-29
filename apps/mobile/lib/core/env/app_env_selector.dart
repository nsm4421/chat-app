import 'package:flutter/foundation.dart';
import 'package:app_env/app_env.dart';

AppEnv resolveAppEnv() {
  if (kIsWeb) {
    return WebAppEnv.current;
  }

  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS => IosAppEnv.current,
    TargetPlatform.android => AndroidAppEnv.current,
    _ => AndroidAppEnv.current,
  };
}
