import 'dart:async';

import 'package:domodachi/features/chat/data/data_source/common/supabase_chat_data_source_handler.dart';
import 'package:domodachi/features/chat/data/data_source/member/chat_room_member_data_source.dart';
import 'package:domodachi/features/chat/data/exception/chat_data_exception.dart';
import 'package:domodachi/features/chat/data/model/chat_room_member_overview_model.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: ChatRoomMemberDataSource)
class SupabaseChatRoomMemberDataSourceImpl
    with SupabaseChatDataSourceHandler
    implements ChatRoomMemberDataSource {
  SupabaseChatRoomMemberDataSourceImpl(this._client);

  final SupabaseClient _client;

  static const _chatRoomMembersTable = 'chat_room_members';
  static const _chatRoomMemberOverviewView = 'chat_room_member_overview';
  static const _memberOverviewColumns =
      'chat_room_id, user_id, is_host, joined_at, anonymous_index';

  @override
  Future<void> join(String chatRoomId) {
    return guardChatRequest(() async {
      final currentUserId = requireCurrentUserId(_client);

      await _client.from(_chatRoomMembersTable).insert({
        'chat_room_id': chatRoomId,
        'user_id': currentUserId,
        // is_host defaults to false
      });
    });
  }

  @override
  Future<void> leave(String chatRoomId) {
    return guardChatRequest(() async {
      final currentUserId = requireCurrentUserId(_client);
      await _client
          .from(_chatRoomMembersTable)
          .delete()
          .eq('chat_room_id', chatRoomId)
          .eq('user_id', currentUserId);
    });
  }

  @override
  Future<bool> isMember({
    required String chatRoomId,
    required String userId,
  }) {
    return guardChatRequest(() async {
      requireCurrentUserId(_client);

      final response = await _client
          .from(_chatRoomMembersTable)
          .select('user_id')
          .eq('chat_room_id', chatRoomId)
          .eq('user_id', userId)
          .limit(1)
          .maybeSingle();

      return response != null;
    });
  }

  @override
  Future<ChatRoomMemberOverviewModel?> getMember({
    required String chatRoomId,
    required String userId,
  }) {
    return guardChatRequest(() async {
      requireCurrentUserId(_client);

      final response = await _client
          .from(_chatRoomMemberOverviewView)
          .select(_memberOverviewColumns)
          .eq('chat_room_id', chatRoomId)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return ChatRoomMemberOverviewModel.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    });
  }

  @override
  Future<Iterable<ChatRoomMemberOverviewModel>> fetchMembers({
    required String chatRoomId,
    int limit = 30,
    String? cursor,
  }) {
    return guardChatRequest(() async {
      requireCurrentUserId(_client);

      dynamic query = _client
          .from(_chatRoomMemberOverviewView)
          .select(_memberOverviewColumns)
          .eq('chat_room_id', chatRoomId);

      if (cursor != null) {
        query = query.lt('joined_at', cursor);
      }

      final response = await query
          .order('joined_at', ascending: false)
          .limit(limit);

      if (response is! List) {
        return const <ChatRoomMemberOverviewModel>[];
      }

      return response
          .map(
            (row) => ChatRoomMemberOverviewModel.fromJson(
              Map<String, dynamic>.from(row as Map),
            ),
          )
          .toList(growable: false);
    });
  }

  @override
  Stream<List<ChatRoomMemberOverviewModel>> watchMembers({
    required String chatRoomId,
  }) {
    RealtimeChannel? channel;

    return Stream.multi((controller) {
      try {
        requireCurrentUserId(_client);

        channel = _client.channel('chat-room-members:$chatRoomId');

        PostgresChangeFilter filter = PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'chat_room_id',
          value: chatRoomId,
        );

        Future<void> emitNow() async {
          try {
            final members = await fetchMembers(
              chatRoomId: chatRoomId,
              // Supabase view returns only active members; max participants is 50.
              limit: 50,
            );
            controller.add(members.toList(growable: false));
          } catch (e, st) {
            controller.addError(e, st);
          }
        }

        void onChange([_]) {
          unawaited(emitNow());
        }

        channel!.onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: _chatRoomMembersTable,
          filter: filter,
          callback: onChange,
        );
        channel!.onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: _chatRoomMembersTable,
          filter: filter,
          callback: onChange,
        );
        channel!.onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: _chatRoomMembersTable,
          filter: filter,
          callback: onChange,
        );

        channel!.subscribe((status, [error]) async {
          if (status == RealtimeSubscribeStatus.subscribed) {
            try {
              await emitNow();
            } catch (e) {
              controller.addError(
                ChatDataException(
                  e.toString(),
                ),
              );
            }
            return;
          }

          if (status == RealtimeSubscribeStatus.channelError ||
              status == RealtimeSubscribeStatus.timedOut) {
            controller.addError(
              ChatDataException(
                error?.toString() ??
                    '실시간 멤버 목록을 구독하지 못했어요. 잠시 후 다시 시도해 주세요.',
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

}
