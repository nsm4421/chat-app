import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

@InjectableInit(
  initializerName: 'initInfraHive',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureInfraHiveDependencies(GetIt getIt) async {
  initInfraHive(getIt);
}
