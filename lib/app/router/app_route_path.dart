abstract final class AppRoutePath {
  static const chatRoomIdParam = 'chatRoomId';
  static const splash = '/splash';
  static const auth = '/auth';
  static const signIn = '/auth/sign-in';
  static const signUp = '/auth/sign-up';
  static const forgotPassword = '/auth/forgot-password';
  static const profileSetup = '/auth/profile-setup';
  static const home = '/';
  static const settings = '/settings';
  static const groupChatRoomRoot = '/chat/room';
  static const groupChatRoom = '$groupChatRoomRoot/:$chatRoomIdParam';
  static const createChatRoom = '/chat/create';
  static const modifyChatRoom = '/chat/modify';

  static String groupChatRoomPath(String chatRoomId) =>
      '$groupChatRoomRoot/$chatRoomId';

  static bool isAuthArea(String path) =>
      path == AppRoutePath.auth ||
      path == AppRoutePath.signIn ||
      path == AppRoutePath.signUp ||
      path == AppRoutePath.forgotPassword;
}
