import 'package:feature_friend/data/exception/friend_data_exception.dart';
import 'package:supabase/supabase.dart';

mixin class SupabaseFriendDataSourceHandler {
  Future<T> guardFriendRequest<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FriendDataException {
      rethrow;
    } on PostgrestException catch (error) {
      throw FriendDataException(error.message);
    } on AuthException catch (error) {
      throw FriendDataException(error.message);
    } catch (error) {
      throw FriendDataException(mapFriendError(error));
    }
  }

  String requireCurrentUserId(SupabaseClient client) {
    final currentUserId = client.auth.currentUser?.id;
    if (currentUserId == null) {
      throw const FriendDataException('로그인이 필요해요. 다시 시도해 주세요.');
    }
    return currentUserId;
  }

  String mapFriendError(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('이미 친구인') || message.contains('already friends')) {
      return '이미 친구인 사용자예요.';
    }

    if (message.contains('이미 친구 요청을 보낸') ||
        message.contains('friend_requests_pending_unique_idx')) {
      return '이미 친구 요청을 보낸 사용자예요.';
    }

    if (message.contains('permission') ||
        message.contains('row-level security') ||
        message.contains('not allowed')) {
      return '이 작업을 수행할 권한이 없어요.';
    }

    if (message.contains('duplicate') ||
        message.contains('unique') ||
        message.contains('already')) {
      return '이미 처리된 친구 요청이에요.';
    }

    if (message.contains('not found')) {
      return '대상을 찾을 수 없어요.';
    }

    return '친구 요청을 처리하지 못했어요. 잠시 후 다시 시도해 주세요.';
  }
}
