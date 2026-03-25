import 'dart:async';

import 'package:domodachi/features/chat/data/data_source/common/supabase_chat_data_source_handler.dart';
import 'package:domodachi/features/chat/data/data_source/message/chat_message_data_source.dart';
import 'package:domodachi/features/chat/data/exception/chat_data_exception.dart';
import 'package:domodachi/features/chat/data/model/chat_message_model.dart';
import 'package:domodachi/features/chat/data/model/chat_message_overview_model.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: ChatMessageDataSource)
class SupabaseChatMessageDataSourceImpl
    with SupabaseChatDataSourceHandler
    implements ChatMessageDataSource {
  SupabaseChatMessageDataSourceImpl(this._client);

  // Writes go to `chat_messages`.
  // Reads come from an overview view that adds stable room-scoped aliases.
  static const _chatMessagesTable = 'chat_messages';
  static const _chatMessageOverviewView = 'chat_message_overview';
  static const _messageColumns =
      'id, chat_room_id, sender_id, content, created_at, updated_at';
  static const _messageOverviewColumns =
      'id, chat_room_id, sender_id, content, created_at, updated_at, anonymous_index';

  final SupabaseClient _client;

  @override
  Future<ChatMessageModel> insert({
    required String chatRoomId,
    required String content,
  }) {
    return guardChatRequest(() async {
      final currentUserId = requireCurrentUserId(_client);

      final response = await _client
          .from(_chatMessagesTable)
          .insert({
            'chat_room_id': chatRoomId,
            'sender_id': currentUserId,
            'content': content.trim(),
          })
          .select(_messageColumns)
          .single();

      return ChatMessageModel.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    });
  }

  @override
  Future<void> softDelete({required String chatMessageId}) {
    return guardChatRequest(() async {
      await _client
          .from(_chatMessagesTable)
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', chatMessageId)
          .eq('sender_id', requireCurrentUserId(_client));
    });
  }

  @override
  Future<Iterable<ChatMessageOverviewModel>> fetchMessages({
    required String chatRoomId,
    int limit = 50,
    String? cursor,
  }) {
    return guardChatRequest(() async {
      requireCurrentUserId(_client);

      dynamic query = _client
          .from(_chatMessageOverviewView)
          .select(_messageOverviewColumns)
          .eq('chat_room_id', chatRoomId);

      if (cursor != null) {
        query = query.lt('created_at', cursor);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      if (response is! List) {
        return const <ChatMessageOverviewModel>[];
      }

      return response
          .map(
            (row) => ChatMessageOverviewModel.fromJson(
              Map<String, dynamic>.from(row as Map),
            ),
          )
          .toList(growable: false);
    });
  }

  @override
  Stream<ChatMessageOverviewModel> watchNewMessages({
    required String chatRoomId,
  }) {
    RealtimeChannel? channel;

    return Stream.multi((controller) {
      try {
        requireCurrentUserId(_client);

        channel = _client.channel('chat-messages:$chatRoomId');
        channel!
            .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              schema: 'public',
              table: _chatMessagesTable,
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'chat_room_id',
                value: chatRoomId,
              ),
              callback: (payload) {
                try {
                  final messageId = payload.newRecord['id'] as String?;
                  if (messageId == null) {
                    throw const ChatDataException('생성된 메시지 정보를 확인하지 못했어요.');
                  }

                  unawaited(
                    _getMessageOverview(
                      messageId,
                    ).then(controller.add).catchError(controller.addError),
                  );
                } catch (error) {
                  controller.addError(
                    ChatDataException(mapChatRoomError(error)),
                  );
                }
              },
            )
            .subscribe((status, [error]) {
              if (status == RealtimeSubscribeStatus.subscribed) {
                return;
              }

              if (status == RealtimeSubscribeStatus.channelError ||
                  status == RealtimeSubscribeStatus.timedOut) {
                controller.addError(
                  ChatDataException(
                    error?.toString() ?? '실시간 메시지를 구독하지 못했어요. 잠시 후 다시 시도해 주세요.',
                  ),
                );
              }
            });
      } on ChatDataException catch (error) {
        controller.addError(error);
        controller.close();
      } catch (error) {
        controller.addError(ChatDataException(mapChatRoomError(error)));
        controller.close();
      }

      controller.onCancel = () {
        final currentChannel = channel;
        if (currentChannel == null) {
          return;
        }

        unawaited(_client.removeChannel(currentChannel));
      };
    });
  }

  Future<ChatMessageOverviewModel> _getMessageOverview(
    String chatMessageId,
  ) async {
    final response = await _client
        .from(_chatMessageOverviewView)
        .select(_messageOverviewColumns)
        .eq('id', chatMessageId)
        .single();

    return ChatMessageOverviewModel.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }
}
