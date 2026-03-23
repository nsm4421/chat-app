import 'package:domodachi/features/chat/data/model/chat_room_presence_event_model.dart';
import 'package:domodachi/features/chat/data/model/chat_room_presence_model.dart';

abstract interface class ChatRoomPresenceDataSource {
  Future<void> enter(String chatRoomId);

  Future<void> leave(String chatRoomId);

  Stream<List<ChatRoomPresenceModel>> watchPresence(String chatRoomId);

  Stream<ChatRoomPresenceEventModel> watchPresenceEvents(String chatRoomId);
}
