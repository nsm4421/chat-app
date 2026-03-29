import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

@InjectableInit(
  initializerName: 'initInfraPreferences',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureInfraPreferencesDependencies(GetIt getIt) async {
  initInfraPreferences(getIt);
}
