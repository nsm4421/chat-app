import 'package:domodachi/features/chat/data/model/chat_room_presence_event_model.dart';
import 'package:domodachi/features/chat/data/model/chat_room_presence_model.dart';

abstract interface class ChatRoomPresenceDataSource {
  Future<void> enter({
    required String chatRoomId,
    required String userId,
    String? displayName,
    String? avatarUrl,
  });

  Future<void> leave({required String chatRoomId});

  Stream<List<ChatRoomPresenceModel>> watchPresence({
    required String chatRoomId,
  });

  Stream<ChatRoomPresenceEventModel> watchPresenceEvents({
    required String chatRoomId,
  });
}
