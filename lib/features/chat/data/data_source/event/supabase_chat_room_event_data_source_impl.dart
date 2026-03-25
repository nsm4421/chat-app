import 'dart:async';

import 'package:domodachi/features/chat/data/data_source/common/supabase_chat_data_source_handler.dart';
import 'package:domodachi/features/chat/data/data_source/event/chat_room_event_data_source.dart';
import 'package:domodachi/features/chat/data/exception/chat_data_exception.dart';
import 'package:domodachi/features/chat/data/model/chat_room_event_overview_model.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: ChatRoomEventDataSource)
class SupabaseChatRoomEventDataSourceImpl
    with SupabaseChatDataSourceHandler
    implements ChatRoomEventDataSource {
  SupabaseChatRoomEventDataSourceImpl(this._client);

  static const _chatRoomEventsTable = 'chat_room_events';
  static const _chatRoomEventOverviewView = 'chat_room_event_overview';
  static const _eventBaseColumns =
      'id, chat_room_id, user_id, type, created_at';
  static const _eventOverviewColumns =
      'id, chat_room_id, user_id, type, created_at, anonymous_index';

  final SupabaseClient _client;

  @override
  Future<Iterable<ChatRoomEventOverviewModel>> fetchEvents({
    required String chatRoomId,
    int limit = 50,
    String? cursor,
  }) {
    return guardChatRequest(() async {
      requireCurrentUserId(_client);
      try {
        return await _fetchEventRows(
          source: _chatRoomEventOverviewView,
          columns: _eventOverviewColumns,
          chatRoomId: chatRoomId,
          limit: limit,
          cursor: cursor,
        );
      } on PostgrestException catch (error) {
        if (!_isMissingOverviewRelation(error)) {
          rethrow;
        }

        // Fallback for databases where the overview view has not been applied
        // yet. Anonymous labels are omitted until the migration is present.
        return _fetchEventRows(
          source: _chatRoomEventsTable,
          columns: _eventBaseColumns,
          chatRoomId: chatRoomId,
          limit: limit,
          cursor: cursor,
        );
      }
    });
  }

  @override
  Stream<ChatRoomEventOverviewModel> watchNewEvents({
    required String chatRoomId,
  }) {
    RealtimeChannel? channel;

    return Stream.multi((controller) {
      try {
        requireCurrentUserId(_client);

        channel = _client.channel('chat-room-events:$chatRoomId');
        channel!
            .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              schema: 'public',
              table: _chatRoomEventsTable,
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'chat_room_id',
                value: chatRoomId,
              ),
              callback: (payload) {
                try {
                  final eventId = payload.newRecord['id'] as String?;
                  if (eventId == null) {
                    throw const ChatDataException('생성된 채팅 이벤트 정보를 확인하지 못했어요.');
                  }

                  unawaited(
                    _getEventOverview(
                      eventId,
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
                    error?.toString() ??
                        '실시간 채팅 이벤트를 구독하지 못했어요. 잠시 후 다시 시도해 주세요.',
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

  @override
  Stream<ChatRoomEventOverviewModel> watchDeletedRoomEvents() {
    RealtimeChannel? channel;

    return Stream.multi((controller) {
      try {
        requireCurrentUserId(_client);

        channel = _client.channel('chat-room-events:deleted');
        channel!
            .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              schema: 'public',
              table: _chatRoomEventsTable,
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'type',
                value: 'room_deleted',
              ),
              callback: (payload) {
                try {
                  final eventId = payload.newRecord['id'] as String?;
                  if (eventId == null) {
                    throw const ChatDataException('생성된 채팅 이벤트 정보를 확인하지 못했어요.');
                  }

                  unawaited(
                    _getEventOverview(
                      eventId,
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
                    error?.toString() ??
                        '실시간 채팅 이벤트를 구독하지 못했어요. 잠시 후 다시 시도해 주세요.',
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

  Future<ChatRoomEventOverviewModel> _getEventOverview(
    String chatRoomEventId,
  ) async {
    try {
      final response = await _client
          .from(_chatRoomEventOverviewView)
          .select(_eventOverviewColumns)
          .eq('id', chatRoomEventId)
          .single();

      return ChatRoomEventOverviewModel.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    } on PostgrestException catch (error) {
      if (!_isMissingOverviewRelation(error)) {
        rethrow;
      }

      final response = await _client
          .from(_chatRoomEventsTable)
          .select(_eventBaseColumns)
          .eq('id', chatRoomEventId)
          .single();

      return ChatRoomEventOverviewModel.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    }
  }

  Future<List<ChatRoomEventOverviewModel>> _fetchEventRows({
    required String source,
    required String columns,
    required String chatRoomId,
    required int limit,
    required String? cursor,
  }) async {
    dynamic query = _client
        .from(source)
        .select(columns)
        .eq('chat_room_id', chatRoomId);

    if (cursor != null) {
      query = query.lt('created_at', cursor);
    }

    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);
    if (response is! List) {
      return const <ChatRoomEventOverviewModel>[];
    }

    return response
        .map(
          (row) => ChatRoomEventOverviewModel.fromJson(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList(growable: false);
  }

  bool _isMissingOverviewRelation(PostgrestException error) {
    final message = error.message.toLowerCase();
    return message.contains('chat_room_event_overview') &&
        (message.contains('does not exist') ||
            message.contains('could not find') ||
            message.contains('relation'));
  }
}
