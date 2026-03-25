import 'package:domodachi/features/chat/data/model/chat_room_event_overview_model.dart';

abstract interface class ChatRoomEventDataSource {
  Future<Iterable<ChatRoomEventOverviewModel>> fetchEvents({
    required String chatRoomId,
    int limit = 50,
    String? cursor,
  });

  Stream<ChatRoomEventOverviewModel> watchNewEvents({
    required String chatRoomId,
  });

  Stream<ChatRoomEventOverviewModel> watchDeletedRoomEvents();
}
