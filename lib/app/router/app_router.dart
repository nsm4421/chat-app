import 'package:domodachi/app/router/app_route_path.dart';
import 'package:domodachi/app/router/auth_router_refresh_notifier.dart';
import 'package:domodachi/features/auth/presentation/cubit/session/auth_session_cubit.dart';
import 'package:domodachi/features/auth/presentation/cubit/session/auth_session_state.dart';
import 'package:domodachi/features/auth/presentation/pages/auth_landing_page.dart';
import 'package:domodachi/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:domodachi/features/auth/presentation/pages/profile_setup_page.dart';
import 'package:domodachi/features/auth/presentation/pages/sign_in_page.dart';
import 'package:domodachi/features/auth/presentation/pages/sign_up_page.dart';
import 'package:domodachi/features/auth/presentation/pages/splash_page.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room.dart';
import 'package:domodachi/features/chat/presentation/pages/create/create_chat_room_page.dart';
import 'package:domodachi/features/chat/presentation/pages/modify/modify_chat_room_page.dart';
import 'package:domodachi/features/chat/presentation/pages/room/group_chat_room_page.dart';
import 'package:domodachi/features/chat/presentation/pages/search/group_chat_search_page.dart';
import 'package:domodachi/features/friend/presentation/pages/friend_hub_page.dart';
import 'package:domodachi/features/home/home_page.dart';
import 'package:domodachi/features/settings/settings_page.dart';
import 'package:domodachi/features/settings/pages/edit_profile_page.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AppRoute {
  AppRoute(this._authSessionCubit);

  final AuthSessionCubit _authSessionCubit;

  GoRouter get routeConfig => _router;

  late final _refreshNotifier = AuthRouterRefreshNotifier(
    _authSessionCubit.stream,
  );

  late final GoRouter _router = GoRouter(
    initialLocation: AppRoutePath.splash,
    refreshListenable: _refreshNotifier,
    redirect: (context, state) {
      final location = state.uri.path;
      final isAuthArea = AppRoutePath.isAuthArea(location);
      final isSplash = location == AppRoutePath.splash;
      final isProfileSetup = location == AppRoutePath.profileSetup;

      return _authSessionCubit.state.when(
        unknown: () => isSplash ? null : AppRoutePath.splash,
        unauthenticated: () => isAuthArea ? null : AppRoutePath.auth,
        profileIncomplete: (_) =>
            isProfileSetup ? null : AppRoutePath.profileSetup,
        authenticated: (_) => (isSplash || isAuthArea || isProfileSetup)
            ? AppRoutePath.home
            : null,
      );
    },
    routes: [
      GoRoute(
        path: AppRoutePath.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutePath.auth,
        builder: (context, state) => const AuthLandingPage(),
      ),
      GoRoute(
        path: AppRoutePath.signIn,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: AppRoutePath.signUp,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: AppRoutePath.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutePath.profileSetup,
        builder: (context, state) => const ProfileSetupPage(),
      ),
      GoRoute(
        path: AppRoutePath.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutePath.friends,
        builder: (context, state) => const FriendHubPage(),
      ),
      GoRoute(
        path: AppRoutePath.createChatRoom,
        builder: (context, state) => const CreateChatRoomPage(),
      ),
      GoRoute(
        path: AppRoutePath.groupChatSearch,
        builder: (context, state) => const GroupChatSearchPage(),
      ),
      GoRoute(
        path: AppRoutePath.groupChatRoom,
        builder: (context, state) => GroupChatRoomPage(
          chatRoomId: state.pathParameters[AppRoutePath.chatRoomIdParam]!,
        ),
      ),
      GoRoute(
        path: AppRoutePath.modifyChatRoom,
        builder: (context, state) =>
            ModifyChatRoomPage(room: state.extra! as ChatRoom),
      ),
      GoRoute(
        path: AppRoutePath.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutePath.editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),
    ],
  );
}
