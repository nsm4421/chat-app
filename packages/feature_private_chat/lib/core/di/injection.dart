import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

@InjectableInit(
  initializerName: 'initFeaturePrivateChat',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureFeaturePrivateChatDependencies(GetIt getIt) async {
  initFeaturePrivateChat(getIt);
}
