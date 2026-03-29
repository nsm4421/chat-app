import 'package:feature_chat_core/chat_core/core/value_objects/chat_room_enums.dart';
import 'package:feature_chat_core/chat_core/data/model/chat_room_model.dart';

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

  Future<Iterable<ChatRoomModel>> searchDiscoverChatRooms({
    required String query,
    int limit = 20,
  });

  Future<ChatRoomModel?> getChatRoom(String chatRoomId);

  /// Creates a private chat room with `otherUserId` or reuses the existing one.
  Future<ChatRoomModel> createOrGetPrivateChatRoom({
    required String otherUserId,
  });

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
