abstract final class AppRoutePath {
  static const splash = '/splash';
  static const auth = '/auth';
  static const signIn = '/auth/sign-in';
  static const signUp = '/auth/sign-up';
  static const forgotPassword = '/auth/forgot-password';
  static const profileSetup = '/auth/profile-setup';
  static const editProfile = '/settings/profile/edit';
  static const home = '/';
  static const settings = '/settings';
  static const mockReplaySetup = '/mock/replay/setup';
  static const mockTradingSession = '/mock/trade/session';
  static const mockSessionResult = '/mock/trade/result';
  static const mockProofDetail = '/mock/proof/detail';
  static const mockSeasonDetail = '/mock/season';

  static bool isAuthArea(String path) =>
      path == AppRoutePath.auth ||
      path == AppRoutePath.signIn ||
      path == AppRoutePath.signUp ||
      path == AppRoutePath.forgotPassword;
}
