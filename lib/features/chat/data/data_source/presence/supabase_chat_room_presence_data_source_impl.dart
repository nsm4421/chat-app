import 'dart:async';

import 'package:domodachi/features/chat/data/data_source/common/supabase_chat_data_source_handler.dart';
import 'package:domodachi/features/chat/data/data_source/presence/chat_room_presence_data_source.dart';
import 'package:domodachi/features/chat/data/exception/chat_data_exception.dart';
import 'package:domodachi/features/chat/data/model/chat_room_presence_event_model.dart';
import 'package:domodachi/features/chat/data/model/chat_room_presence_model.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: ChatRoomPresenceDataSource)
class SupabaseChatRoomPresenceDataSourceImpl
    with SupabaseChatDataSourceHandler
    implements ChatRoomPresenceDataSource {
  SupabaseChatRoomPresenceDataSourceImpl(this._client);

  final SupabaseClient _client;
  final Map<String, _PresenceRoomSession> _sessions =
      <String, _PresenceRoomSession>{};

  @override
  Future<void> enter({
    required String chatRoomId,
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) async {
    requireCurrentUserId(_client);

    final session = _ensureSession(chatRoomId);
    session.selfPayload = <String, dynamic>{
      'user_id': userId,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'online_at': DateTime.now().toIso8601String(),
    };

    if (session.isSubscribed) {
      await _track(session);
    }
  }

  @override
  Future<void> leave({required String chatRoomId}) async {
    final session = _sessions[chatRoomId];
    if (session == null) {
      return;
    }

    await session.channel.untrack();
    session.selfPayload = null;
  }

  @override
  Stream<List<ChatRoomPresenceModel>> watchPresence({
    required String chatRoomId,
  }) {
    return _ensureSession(chatRoomId).presenceController.stream;
  }

  @override
  Stream<ChatRoomPresenceEventModel> watchPresenceEvents({
    required String chatRoomId,
  }) {
    return _ensureSession(chatRoomId).eventController.stream;
  }

  _PresenceRoomSession _ensureSession(String chatRoomId) {
    final existing = _sessions[chatRoomId];
    if (existing != null) {
      return existing;
    }

    final session = _PresenceRoomSession(
      channel: _client.channel('chat-room-presence:$chatRoomId'),
    );

    session.channel
        .onPresenceSync((_) {
          session.presenceController.add(_toPresenceModels(session.channel));
        })
        .onPresenceJoin((payload) {
          for (final presence in payload.newPresences) {
            final model = _toPresenceModel(presence);
            if (model != null) {
              session.eventController.add(
                ChatRoomPresenceEventModel(
                  type: ChatRoomPresenceEventType.joined,
                  presence: model,
                ),
              );
            }
          }
          session.presenceController.add(_toPresenceModels(session.channel));
        })
        .onPresenceLeave((payload) {
          for (final presence in payload.leftPresences) {
            final model = _toPresenceModel(presence);
            if (model != null) {
              session.eventController.add(
                ChatRoomPresenceEventModel(
                  type: ChatRoomPresenceEventType.left,
                  presence: model,
                ),
              );
            }
          }
          session.presenceController.add(_toPresenceModels(session.channel));
        })
        .subscribe((status, [error]) async {
          if (status == RealtimeSubscribeStatus.subscribed) {
            session.isSubscribed = true;
            try {
              await _track(session);
            } catch (trackError) {
              session.presenceController.addError(
                ChatDataException(mapChatRoomError(trackError)),
              );
            }
            return;
          }

          if (status == RealtimeSubscribeStatus.channelError ||
              status == RealtimeSubscribeStatus.timedOut) {
            session.presenceController.addError(
              ChatDataException(
                error?.toString() ?? '실시간 접속 상태를 구독하지 못했어요. 잠시 후 다시 시도해 주세요.',
              ),
            );
          }
        });

    _sessions[chatRoomId] = session;
    return session;
  }

  Future<void> _track(_PresenceRoomSession session) async {
    final payload = session.selfPayload;
    if (payload == null) {
      return;
    }

    final response = await session.channel.track(payload);
    if (response != ChannelResponse.ok) {
      throw const ChatDataException('실시간 접속 상태를 등록하지 못했어요.');
    }
  }

  List<ChatRoomPresenceModel> _toPresenceModels(RealtimeChannel channel) {
    return channel
        .presenceState()
        .expand((state) {
          return state.presences
              .map(_toPresenceModel)
              .whereType<ChatRoomPresenceModel>();
        })
        .toList(growable: false);
  }

  ChatRoomPresenceModel? _toPresenceModel(Presence presence) {
    final userId = presence.payload['user_id'] as String?;
    if (userId == null || userId.isEmpty) {
      return null;
    }

    return ChatRoomPresenceModel(
      userId: userId,
      presenceRef: presence.presenceRef,
      displayName: presence.payload['display_name'] as String?,
      avatarUrl: presence.payload['avatar_url'] as String?,
      onlineAt: DateTime.tryParse(
        presence.payload['online_at'] as String? ?? '',
      ),
    );
  }
}

final class _PresenceRoomSession {
  _PresenceRoomSession({required this.channel});

  final RealtimeChannel channel;
  final StreamController<List<ChatRoomPresenceModel>> presenceController =
      StreamController<List<ChatRoomPresenceModel>>.broadcast();
  final StreamController<ChatRoomPresenceEventModel> eventController =
      StreamController<ChatRoomPresenceEventModel>.broadcast();
  Map<String, dynamic>? selfPayload;
  bool isSubscribed = false;
}
