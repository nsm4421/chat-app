import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

@InjectableInit(
  initializerName: 'initFeatureChatCore',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureFeatureChatCoreDependencies(GetIt getIt) async {
  initFeatureChatCore(getIt);
}
