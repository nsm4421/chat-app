import 'package:app_ui/app_ui.dart';
import 'package:domodachi/app/router/app_router.dart';
import 'package:feature_auth/data/data_source/auth_data_source.dart';
import 'package:feature_auth/data/repository/auth_repository_impl.dart';
import 'package:feature_auth/domain/repository/auth_repository.dart';
import 'package:feature_auth/domain/use_case/auth_use_cases.dart';
import 'package:feature_auth/presentation/cubit/account/delete_account_cubit.dart';
import 'package:feature_auth/presentation/cubit/password_reset/password_reset_cubit.dart';
import 'package:feature_auth/presentation/cubit/session/auth_session_cubit.dart';
import 'package:feature_auth/presentation/cubit/sign_in/sign_in_cubit.dart';
import 'package:feature_auth/presentation/cubit/sign_up/sign_up_cubit.dart';
import 'package:feature_market/data/data_source/market_data_source.dart';
import 'package:feature_market/data/data_source/unimplemented_market_data_source.dart';
import 'package:feature_market/data/repository/market_repository_impl.dart';
import 'package:feature_market/domain/repository/market_repository.dart';
import 'package:feature_market/domain/use_case/market_use_cases.dart';
import 'package:feature_profile/data/data_source/profile_data_source.dart';
import 'package:feature_profile/data/repository/profile_repository_impl.dart';
import 'package:feature_profile/domain/repository/profile_repository.dart';
import 'package:feature_profile/domain/use_case/profile_use_cases.dart';
import 'package:feature_profile/presentation/cubit/profile_edit/profile_edit_cubit.dart';
import 'package:feature_profile/presentation/cubit/profile_setup/profile_setup_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:infra_hive/core/hive_initializer.dart';
import 'package:infra_supabase/auth/supabase_auth_data_source_impl.dart';
import 'package:infra_supabase/profile/supabase_profile_data_source_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> configureDependencies() async {
  final getIt = GetIt.instance;

  await getIt.reset();

  final sharedPreferences = await SharedPreferences.getInstance();
  final hive = await HiveInitializer.initialize();
  final supabaseClient = Supabase.instance.client;

  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerSingleton<HiveInterface>(hive);
  getIt.registerSingleton<SupabaseClient>(supabaseClient);

  getIt.registerLazySingleton<ThemeModeCubit>(
    () => ThemeModeCubit(getIt()),
  );

  getIt.registerLazySingleton<AuthDataSource>(
    () => SupabaseAuthDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<AuthUseCases>(
    () => AuthUseCases(getIt()),
  );
  getIt.registerLazySingleton<AuthSessionCubit>(
    () => AuthSessionCubit(getIt()),
  );
  getIt.registerFactory<SignInCubit>(() => SignInCubit(getIt()));
  getIt.registerFactory<SignUpCubit>(() => SignUpCubit(getIt()));
  getIt.registerFactory<PasswordResetCubit>(
    () => PasswordResetCubit(getIt()),
  );
  getIt.registerFactory<DeleteAccountCubit>(
    () => DeleteAccountCubit(getIt()),
  );

  getIt.registerLazySingleton<ProfileDataSource>(
    () => SupabaseProfileDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<ProfileUseCases>(
    () => ProfileUseCases(getIt()),
  );
  getIt.registerFactory<ProfileSetupCubit>(() => ProfileSetupCubit(getIt()));
  getIt.registerFactory<ProfileEditCubit>(() => ProfileEditCubit(getIt()));

  getIt.registerLazySingleton<MarketDataSource>(
    UnimplementedMarketDataSource.new,
  );
  getIt.registerLazySingleton<MarketRepository>(
    () => MarketRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<MarketUseCases>(
    () => MarketUseCases(getIt()),
  );

  getIt.registerLazySingleton<AppRoute>(() => AppRoute(getIt()));
}
