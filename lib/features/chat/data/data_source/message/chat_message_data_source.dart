import 'package:domodachi/features/chat/data/model/chat_message_model.dart';
import 'package:domodachi/features/chat/data/model/chat_message_overview_model.dart';

abstract interface class ChatMessageDataSource {
  Future<ChatMessageModel> insert({
    required String chatRoomId,
    required String content,
  });

  Future<void> softDelete({required String chatMessageId});

  /// Returns a page of recent messages for the room.
  ///
  /// Implementations should use `cursor` to page older messages.
  Future<Iterable<ChatMessageOverviewModel>> fetchMessages({
    required String chatRoomId,
    int limit = 50,
    String? cursor,
  });

  /// Emits newly inserted messages for the room in realtime.
  Stream<ChatMessageOverviewModel> watchNewMessages({
    required String chatRoomId,
  });
}
