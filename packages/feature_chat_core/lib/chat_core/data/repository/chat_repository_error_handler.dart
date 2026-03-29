import 'package:feature_chat_core/chat_core/data/exception/chat_data_exception.dart';
import 'package:feature_chat_core/chat_core/domain/failure/chat_failure.dart';

mixin class ChatRepositoryErrorHandler {
  Future<T> guardChatRequest<T>(
    Future<T> Function() action, {
    required String fallbackMessage,
  }) async {
    try {
      return await action();
    } on ChatDataException catch (error) {
      throw ChatFailure(mapChatError(error.message));
    } catch (_) {
      throw ChatFailure(fallbackMessage);
    }
  }

  String mapChatError(String rawMessage) {
    final message = rawMessage.toLowerCase();

    if (message.contains('권한')) {
      return '이 작업을 수행할 권한이 없어요.';
    }
    if (message.contains('로그인이 필요')) {
      return '로그인이 필요해요. 다시 시도해 주세요.';
    }
    if (message.contains('이미 처리된 요청')) {
      return '이미 처리된 요청이에요.';
    }
    if (message.contains('duplicate') ||
        message.contains('unique') ||
        message.contains('already')) {
      return '이미 참여 중인 채팅방이거나 중복된 요청이에요.';
    }

    return rawMessage;
  }
}
