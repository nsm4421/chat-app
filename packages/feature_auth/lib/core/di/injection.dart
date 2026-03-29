import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

@InjectableInit(
  initializerName: 'initFeatureAuth',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureFeatureAuthDependencies(GetIt getIt) async {
  initFeatureAuth(getIt);
}
