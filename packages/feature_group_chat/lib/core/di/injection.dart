import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

@InjectableInit(
  initializerName: 'initFeatureGroupChat',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureFeatureGroupChatDependencies(GetIt getIt) async {
  initFeatureGroupChat(getIt);
}
