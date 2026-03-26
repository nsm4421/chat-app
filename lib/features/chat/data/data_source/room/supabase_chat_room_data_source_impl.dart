import 'package:domodachi/features/chat/data/data_source/common/supabase_chat_data_source_handler.dart';
import 'package:domodachi/features/chat/data/data_source/room/chat_room_data_source.dart';
import 'package:domodachi/features/chat/data/exception/chat_data_exception.dart';
import 'package:domodachi/features/chat/data/model/chat_room_model.dart';
import 'package:domodachi/features/chat/core/value_objects/chat_room_enums.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: ChatRoomDataSource)
class SupabaseChatRoomDataSourceImpl
    with SupabaseChatDataSourceHandler
    implements ChatRoomDataSource {
  SupabaseChatRoomDataSourceImpl(this._client);

  static const _chatRoomsTable = 'chat_rooms';
  static const _chatRoomOverviewView = 'chat_room_overview';
  static const _createOrGetPrivateChatRoomRpc =
      'create_or_get_private_chat_room';
  static const _roomColumns =
      'id, created_by, type, title, description, tags, '
      'max_participants, status, is_public, last_message_at, created_at, updated_at, '
      'member_count, is_joined, is_host';

  final SupabaseClient _client;

  @override
  Future<Iterable<ChatRoomModel>> fetchDiscoverChatRooms({
    int limit = 20,
    String? cursor,
  }) {
    return guardChatRequest(() async {
      dynamic query = _client
          .from(_chatRoomOverviewView)
          .select(_roomColumns)
          .eq('type', ChatRoomType.group.name)
          .eq('is_public', true)
          .inFilter('status', [
            ChatRoomStatus.open.name,
            ChatRoomStatus.full.name,
          ]);

      if (cursor != null) {
        query = query.lt('last_message_at', cursor);
      }

      final response = await query
          .order('last_message_at', ascending: false, nullsFirst: false)
          .order('created_at', ascending: false)
          .limit(limit);

      return toChatRooms(response);
    });
  }

  @override
  Future<Iterable<ChatRoomModel>> fetchJoinedChatRooms({
    int limit = 20,
    String? cursor,
    ChatRoomType? type,
  }) {
    return guardChatRequest(() async {
      requireCurrentUserId(_client);

      dynamic query = _client
          .from(_chatRoomOverviewView)
          .select('$_roomColumns, joined_at')
          .eq('is_joined', true);

      if (type != null) {
        query = query.eq('type', type.name);
      }

      if (cursor != null) {
        query = query.lt('joined_at', cursor);
      }

      final response = await query
          .order('joined_at', ascending: false)
          .order('last_message_at', ascending: false, nullsFirst: false)
          .limit(limit);

      return toChatRooms(response);
    });
  }

  @override
  Future<Iterable<ChatRoomModel>> searchDiscoverChatRooms({
    required String query,
    int limit = 20,
  }) {
    return guardChatRequest(() async {
      final normalizedQuery = query.trim().replaceFirst(RegExp(r'^#'), '');
      if (normalizedQuery.length < 2) {
        return const <ChatRoomModel>[];
      }

      final titleResponse = await _client
          .from(_chatRoomOverviewView)
          .select(_roomColumns)
          .eq('type', ChatRoomType.group.name)
          .eq('is_public', true)
          .inFilter('status', [
            ChatRoomStatus.open.name,
            ChatRoomStatus.full.name,
          ])
          .ilike('title', '%$normalizedQuery%')
          .order('last_message_at', ascending: false, nullsFirst: false)
          .order('created_at', ascending: false)
          .limit(limit);

      final roomsById = <String, ChatRoomModel>{
        for (final room in toChatRooms(titleResponse)) room.id: room,
      };

      final tagResponse = await _client
          .from(_chatRoomOverviewView)
          .select(_roomColumns)
          .eq('type', ChatRoomType.group.name)
          .eq('is_public', true)
          .inFilter('status', [
            ChatRoomStatus.open.name,
            ChatRoomStatus.full.name,
          ])
          .contains('tags', [normalizedQuery])
          .order('last_message_at', ascending: false, nullsFirst: false)
          .order('created_at', ascending: false)
          .limit(limit);

      for (final room in toChatRooms(tagResponse)) {
        roomsById[room.id] = room;
      }

      final rooms = roomsById.values.toList(growable: false);
      rooms.sort((a, b) {
        final aTime = a.lastMessageAt ?? a.createdAt;
        final bTime = b.lastMessageAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });

      if (rooms.length <= limit) {
        return rooms;
      }

      return rooms.take(limit).toList(growable: false);
    });
  }

  @override
  Future<ChatRoomModel?> getChatRoom(String chatRoomId) {
    return guardChatRequest(() async {
      final response = await _client
          .from(_chatRoomOverviewView)
          .select(_roomColumns)
          .eq('id', chatRoomId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return ChatRoomModel.fromJson(Map<String, dynamic>.from(response as Map));
    });
  }

  @override
  Future<ChatRoomModel> createOrGetPrivateChatRoom({
    required String otherUserId,
  }) {
    return guardChatRequest(() async {
      requireCurrentUserId(_client);

      final response = await _client.rpc(
        _createOrGetPrivateChatRoomRpc,
        params: {'other_user_id': otherUserId},
      );

      final chatRoomId = response as String?;
      if (chatRoomId == null || chatRoomId.isEmpty) {
        throw const ChatDataException('DM 채팅방을 열지 못했어요.');
      }

      final room = await getChatRoom(chatRoomId);
      if (room == null) {
        throw const ChatDataException('DM 채팅방 정보를 불러오지 못했어요.');
      }

      return room;
    });
  }

  @override
  Future<ChatRoomModel> createChatRoom({
    required ChatRoomStatus status,
    required ChatRoomType type,
    required int maxParticipants,
    required bool isPublic,
    String? title,
    String? description,
    List<String> tags = const <String>[],
  }) {
    return guardChatRequest(() async {
      final currentUserId = requireCurrentUserId(_client);

      final response = await _client
          .from(_chatRoomsTable)
          .insert({
            'created_by': currentUserId,
            'type': type.name,
            'status': status.name,
            'title': title?.trim(),
            'description': description?.trim(),
            'tags': tags.map((tag) => tag.trim()).toList(growable: false),
            'max_participants': maxParticipants,
            'is_public': isPublic,
          })
          .select('id')
          .single();

      final createdChatRoomId = (response as Map)['id'] as String;
      final createdChatRoom = await getChatRoom(createdChatRoomId);
      if (createdChatRoom == null) {
        throw const ChatDataException('생성된 채팅방을 불러오지 못했어요.');
      }
      return createdChatRoom;
    });
  }

  @override
  Future<void> updateChatRoom({
    required String chatRoomId,
    String? title,
    String? description,
    List<String>? tags,
    int? maxParticipants,
    ChatRoomStatus? status,
    bool? isPublic,
  }) {
    return guardChatRequest(() async {
      final payload = <String, dynamic>{};

      if (title != null) {
        payload['title'] = title.trim();
      }
      if (description != null) {
        payload['description'] = description.trim();
      }
      if (tags != null) {
        payload['tags'] = tags.map((tag) => tag.trim()).toList(growable: false);
      }
      if (maxParticipants != null) {
        payload['max_participants'] = maxParticipants;
      }
      if (status != null) {
        payload['status'] = status.name;
      }
      if (isPublic != null) {
        payload['is_public'] = isPublic;
      }

      if (payload.isEmpty) {
        return;
      }

      await _client.from(_chatRoomsTable).update(payload).eq('id', chatRoomId);
    });
  }

  @override
  Future<void> softDeleteChatRoom(String chatRoomId) {
    return guardChatRequest(() async {
      await _client
          .from(_chatRoomsTable)
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', chatRoomId);
    });
  }
}
