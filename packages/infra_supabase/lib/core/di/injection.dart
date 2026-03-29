import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

@InjectableInit(
  initializerName: 'initInfraSupabase',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureInfraSupabaseDependencies(GetIt getIt) async {
  initInfraSupabase(getIt);
}
