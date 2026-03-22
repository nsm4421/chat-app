import 'package:domodachi/features/chat/data/exception/chat_data_exception.dart';
import 'package:domodachi/features/chat/data/model/chat_room_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

mixin class SupabaseChatDataSourceHandler {
  Future<T> guardChatRequest<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ChatDataException {
      rethrow;
    } on PostgrestException catch (error) {
      throw ChatDataException(error.message);
    } on AuthException catch (error) {
      throw ChatDataException(error.message);
    } catch (error) {
      throw ChatDataException(mapChatRoomError(error));
    }
  }

  String mapChatRoomError(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('permission') ||
        message.contains('row-level security') ||
        message.contains('not allowed')) {
      return '이 작업을 수행할 권한이 없어요.';
    }

    if (message.contains('duplicate') ||
        message.contains('unique') ||
        message.contains('already exists')) {
      return '이미 처리된 요청이에요.';
    }

    return '채팅방 요청을 처리하지 못했어요. 잠시 후 다시 시도해 주세요.';
  }

  String requireCurrentUserId(SupabaseClient client) {
    final currentUserId = client.auth.currentUser?.id;
    if (currentUserId == null) {
      throw const ChatDataException('로그인이 필요해요. 다시 시도해 주세요.');
    }
    return currentUserId;
  }

  List<ChatRoomModel> toChatRooms(dynamic response) {
    if (response is! List) {
      return const <ChatRoomModel>[];
    }

    return response
        .map(
          (row) =>
              ChatRoomModel.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList(growable: false);
  }
}
