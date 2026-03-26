import 'package:domodachi/features/friend/data/exception/friend_data_exception.dart';
import 'package:domodachi/features/friend/domain/failure/friend_failure.dart';

mixin class FriendRepositoryErrorHandler {
  Future<T> guardFriendRequest<T>(
    Future<T> Function() action, {
    required String fallbackMessage,
  }) async {
    try {
      return await action();
    } on FriendDataException catch (error) {
      throw FriendFailure(mapFriendError(error.message));
    } catch (_) {
      throw FriendFailure(fallbackMessage);
    }
  }

  String mapFriendError(String rawMessage) {
    final message = rawMessage.toLowerCase();

    if (message.contains('이미 친구인') || message.contains('already friends')) {
      return '이미 친구인 사용자예요.';
    }

    if (message.contains('이미 친구 요청을 보낸') ||
        message.contains('friend_requests_pending_unique_idx')) {
      return '이미 친구 요청을 보낸 사용자예요.';
    }

    if (message.contains('already') ||
        message.contains('duplicate') ||
        message.contains('unique')) {
      return '이미 처리된 친구 요청이에요.';
    }

    if (message.contains('not found') || message.contains('찾을 수 없')) {
      return '대상을 찾을 수 없어요.';
    }

    if (message.contains('permission') ||
        message.contains('권한') ||
        message.contains('row-level security')) {
      return '이 작업을 수행할 권한이 없어요.';
    }

    return rawMessage;
  }
}
