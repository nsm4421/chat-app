import 'package:feature_auth/feature_auth.dart' as feature_auth;
import 'package:feature_chat_core/feature_chat_core.dart' as feature_chat_core;
import 'package:feature_friend/feature_friend.dart' as feature_friend;
import 'package:feature_group_chat/feature_group_chat.dart' as feature_group_chat;
import 'package:feature_profile/feature_profile.dart' as feature_profile;
import 'package:feature_private_chat/feature_private_chat.dart'
    as feature_private_chat;
import 'package:get_it/get_it.dart';
import 'package:infra_hive/infra_hive.dart' as infra_hive;
import 'package:infra_preferences/infra_preferences.dart' as infra_preferences;
import 'package:infra_supabase/infra_supabase.dart' as infra_supabase;
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies() async {
  await GetIt.instance.reset();
  await init(GetIt.instance);
  await infra_hive.configureInfraHiveDependencies(GetIt.instance);
  await infra_preferences.configureInfraPreferencesDependencies(GetIt.instance);
  await infra_supabase.configureInfraSupabaseDependencies(GetIt.instance);
  await feature_auth.configureFeatureAuthDependencies(GetIt.instance);
  await feature_profile.configureFeatureProfileDependencies(GetIt.instance);
  await feature_friend.configureFeatureFriendDependencies(GetIt.instance);
  await feature_chat_core.configureFeatureChatCoreDependencies(GetIt.instance);
  await feature_group_chat.configureFeatureGroupChatDependencies(GetIt.instance);
  await feature_private_chat.configureFeaturePrivateChatDependencies(
    GetIt.instance,
  );
}
