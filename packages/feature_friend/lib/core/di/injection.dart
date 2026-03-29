import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

@InjectableInit(
  initializerName: 'initFeatureFriend',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureFeatureFriendDependencies(GetIt getIt) async {
  initFeatureFriend(getIt);
}
