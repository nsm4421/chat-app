import 'package:domodachi/features/chat/core/value_objects/chat_room_enums.dart';
import 'package:domodachi/features/chat/data/model/chat_room_model.dart';

abstract interface class ChatRoomDataSource {
  Future<Iterable<ChatRoomModel>> fetchDiscoverChatRooms({
    int limit = 20,
    String? cursor,
  });

  Future<Iterable<ChatRoomModel>> fetchJoinedChatRooms({
    int limit = 20,
    String? cursor,
    ChatRoomType? type,
  });

  Future<ChatRoomModel?> getChatRoom(String chatRoomId);

  Future<ChatRoomModel> createChatRoom({
    required ChatRoomStatus status,
    required ChatRoomType type,
    required int maxParticipants,
    required bool isPublic,
    String? title,
    String? description,
    List<String> tags = const <String>[],
  });

  Future<void> updateChatRoom({
    required String chatRoomId,
    String? title,
    String? description,
    List<String>? tags,
    int? maxParticipants,
    ChatRoomStatus? status,
    bool? isPublic,
  });

  Future<void> softDeleteChatRoom(String chatRoomId);
}
