import 'package:domodachi/features/chat/data/data_source/local/chat_room_draft_local_data_source.dart';
import 'package:domodachi/features/chat/data/data_source/member/chat_room_member_data_source.dart';
import 'package:domodachi/features/chat/data/data_source/room/chat_room_data_source.dart';
import 'package:domodachi/features/chat/data/mapper/chat_room_mapper.dart';
import 'package:domodachi/features/chat/data/model/chat_room_draft_model.dart';
import 'package:domodachi/features/chat/data/repository/chat_repository_error_handler.dart';
import 'package:domodachi/features/chat/core/value_objects/chat_room_enums.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room.dart';
import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl
    with ChatRepositoryErrorHandler
    implements ChatRepository {
  ChatRepositoryImpl(
    this._chatRoomDataSource,
    this._chatRoomMemberDataSource,
    this._chatRoomDraftLocalDataSource,
  );

  final ChatRoomDataSource _chatRoomDataSource;
  final ChatRoomMemberDataSource _chatRoomMemberDataSource;
  final ChatRoomDraftLocalDataSource _chatRoomDraftLocalDataSource;

  @override
  Future<ChatRoom?> getDraftChatRoom() async {
    return guardChatRequest(() async {
      final draft = await _chatRoomDraftLocalDataSource.getDraft();
      return draft?.toChatRoom();
    }, fallbackMessage: '임시 저장한 채팅방을 불러오지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  @override
  Future<void> deleteDraftChatRoom() async {
    await guardChatRequest(() async {
      await _chatRoomDraftLocalDataSource.deleteDraft();
    }, fallbackMessage: '임시 저장한 채팅방을 삭제하지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  @override
  Future<List<ChatRoom>> fetchDiscoverChatRooms({
    int limit = 20,
    String? cursor,
  }) async {
    return guardChatRequest(() async {
      final rooms = await _chatRoomDataSource.fetchDiscoverChatRooms(
        limit: limit,
        cursor: cursor,
      );

      return rooms.map((room) => room.toChatRoom()).toList(growable: false);
    }, fallbackMessage: '채팅방 목록을 불러오지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  @override
  Future<List<ChatRoom>> fetchJoinedChatRooms({
    int limit = 20,
    String? cursor,
    ChatRoomType? type,
  }) async {
    return guardChatRequest(() async {
      final rooms = await _chatRoomDataSource.fetchJoinedChatRooms(
        limit: limit,
        cursor: cursor,
        type: type,
      );

      return rooms.map((room) => room.toChatRoom()).toList(growable: false);
    }, fallbackMessage: '참여 중인 채팅방을 불러오지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  @override
  Future<ChatRoom?> getChatRoom(String chatRoomId) async {
    return guardChatRequest(() async {
      final room = await _chatRoomDataSource.getChatRoom(chatRoomId);
      return room?.toChatRoom();
    }, fallbackMessage: '채팅방 정보를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  @override
  Future<ChatRoom> saveDraftChatRoom({
    required ChatRoomType type,
    required int maxParticipants,
    required bool isPublic,
    String? title,
    String? description,
    List<String> tags = const <String>[],
  }) async {
    return guardChatRequest(() async {
      final draft = ChatRoomDraftModel(
        type: type,
        title: title?.trim() ?? '',
        description: description?.trim() ?? '',
        tags: tags.map((tag) => tag.trim()).toList(growable: false),
        maxParticipants: maxParticipants,
        isPublic: isPublic,
        savedAt: DateTime.now(),
      );

      await _chatRoomDraftLocalDataSource.saveDraft(draft);
      return draft.toChatRoom();
    }, fallbackMessage: '임시 저장하지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  @override
  Future<ChatRoom> createRemoteChatRoom({
    required ChatRoomStatus status,
    required ChatRoomType type,
    required int maxParticipants,
    required bool isPublic,
    String? title,
    String? description,
    List<String> tags = const <String>[],
  }) async {
    return guardChatRequest(() async {
      final room = await _chatRoomDataSource.createChatRoom(
        status: status,
        type: type,
        maxParticipants: maxParticipants,
        isPublic: isPublic,
        title: title,
        description: description,
        tags: tags,
      );
      await _chatRoomDraftLocalDataSource.deleteDraft();

      return room.toChatRoom();
    }, fallbackMessage: '채팅방을 만들지 못했어요. 잠시 후 다시 시도해 주세요.');
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
  }) async {
    await guardChatRequest(() async {
      await _chatRoomDataSource.updateChatRoom(
        chatRoomId: chatRoomId,
        title: title,
        description: description,
        tags: tags,
        maxParticipants: maxParticipants,
        status: status,
        isPublic: isPublic,
      );
    }, fallbackMessage: '채팅방을 수정하지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  @override
  Future<void> joinChatRoom(String chatRoomId) async {
    await guardChatRequest(() async {
      await _chatRoomMemberDataSource.insert(chatRoomId: chatRoomId);
    }, fallbackMessage: '채팅방에 참여하지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  @override
  Future<void> leaveChatRoom(String chatRoomId) async {
    await guardChatRequest(() async {
      await _chatRoomMemberDataSource.delete(chatRoomId: chatRoomId);
    }, fallbackMessage: '채팅방에서 나가지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  @override
  Future<void> deleteChatRoom(String chatRoomId) async {
    await guardChatRequest(() async {
      await _chatRoomDataSource.softDeleteChatRoom(chatRoomId);
    }, fallbackMessage: '채팅방을 삭제하지 못했어요. 잠시 후 다시 시도해 주세요.');
  }
}
