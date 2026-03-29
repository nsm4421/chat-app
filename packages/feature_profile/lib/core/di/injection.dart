import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

@InjectableInit(
  initializerName: 'initFeatureProfile',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureFeatureProfileDependencies(GetIt getIt) async {
  initFeatureProfile(getIt);
}
