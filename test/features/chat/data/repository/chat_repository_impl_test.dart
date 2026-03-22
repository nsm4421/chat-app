import 'package:domodachi/features/chat/core/value_objects/chat_room_enums.dart';
import 'package:domodachi/features/chat/data/data_source/local/chat_room_draft_local_data_source.dart';
import 'package:domodachi/features/chat/data/data_source/member/chat_room_member_data_source.dart';
import 'package:domodachi/features/chat/data/data_source/room/chat_room_data_source.dart';
import 'package:domodachi/features/chat/data/model/chat_room_draft_model.dart';
import 'package:domodachi/features/chat/data/model/chat_room_model.dart';
import 'package:domodachi/features/chat/data/repository/chat_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeChatRoomDataSource chatRoomDataSource;
  late _FakeChatRoomMemberDataSource chatRoomMemberDataSource;
  late _FakeChatRoomDraftLocalDataSource chatRoomDraftLocalDataSource;
  late ChatRepositoryImpl repository;

  setUp(() {
    chatRoomDataSource = _FakeChatRoomDataSource();
    chatRoomMemberDataSource = _FakeChatRoomMemberDataSource();
    chatRoomDraftLocalDataSource = _FakeChatRoomDraftLocalDataSource();
    repository = ChatRepositoryImpl(
      chatRoomDataSource,
      chatRoomMemberDataSource,
      chatRoomDraftLocalDataSource,
    );
  });

  group('saveDraftChatRoom', () {
    test('saves to local draft store', () async {
      final room = await repository.saveDraftChatRoom(
        type: ChatRoomType.group,
        maxParticipants: 8,
        isPublic: true,
        title: '임시 채팅방',
        description: '임시 설명',
        tags: const ['coffee'],
      );

      expect(chatRoomDraftLocalDataSource.savedDraft, isNotNull);
      expect(chatRoomDataSource.createCallCount, 0);
      expect(room.status, ChatRoomStatus.draft);
      expect(room.title, '임시 채팅방');
    });
  });

  group('createRemoteChatRoom', () {
    test('saves to remote store and clears local draft', () async {
      final room = await repository.createRemoteChatRoom(
        status: ChatRoomStatus.open,
        type: ChatRoomType.group,
        maxParticipants: 8,
        isPublic: true,
        title: '공개 채팅방',
        description: '설명',
        tags: const ['design'],
      );

      expect(chatRoomDataSource.createCallCount, 1);
      expect(chatRoomDataSource.lastStatus, ChatRoomStatus.open);
      expect(chatRoomDraftLocalDataSource.deleteCallCount, 1);
      expect(room.id, 'remote-room-id');
      expect(room.status, ChatRoomStatus.open);
    });
  });
}

final class _FakeChatRoomDataSource implements ChatRoomDataSource {
  int createCallCount = 0;
  ChatRoomStatus? lastStatus;

  @override
  Future<ChatRoomModel> createChatRoom({
    required ChatRoomStatus status,
    required ChatRoomType type,
    required int maxParticipants,
    required bool isPublic,
    String? title,
    String? description,
    List<String> tags = const <String>[],
  }) async {
    createCallCount += 1;
    lastStatus = status;

    return ChatRoomModel(
      id: 'remote-room-id',
      createdBy: 'remote-user-id',
      type: type,
      status: status,
      title: title,
      description: description,
      tags: tags,
      maxParticipants: maxParticipants,
      isPublic: isPublic,
      createdAt: DateTime(2026, 3, 22, 16),
      updatedAt: DateTime(2026, 3, 22, 16),
      memberCount: 1,
      isJoined: true,
      isHost: true,
    );
  }

  @override
  Future<void> softDeleteChatRoom(String chatRoomId) async {}

  @override
  Future<Iterable<ChatRoomModel>> fetchDiscoverChatRooms({
    int limit = 20,
    String? cursor,
  }) async => const [];

  @override
  Future<Iterable<ChatRoomModel>> fetchJoinedChatRooms({
    int limit = 20,
    String? cursor,
    ChatRoomType? type,
  }) async => const [];

  @override
  Future<ChatRoomModel?> getChatRoom(String chatRoomId) async => null;

  @override
  Future<void> updateChatRoom({
    required String chatRoomId,
    String? title,
    String? description,
    List<String>? tags,
    int? maxParticipants,
    ChatRoomStatus? status,
    bool? isPublic,
  }) async {}
}

final class _FakeChatRoomMemberDataSource implements ChatRoomMemberDataSource {
  @override
  Future<void> delete({required String chatRoomId}) async {}

  @override
  Future<void> insert({required String chatRoomId}) async {}
}

final class _FakeChatRoomDraftLocalDataSource
    implements ChatRoomDraftLocalDataSource {
  ChatRoomDraftModel? savedDraft;
  int deleteCallCount = 0;

  @override
  Future<void> deleteDraft() async {
    deleteCallCount += 1;
    savedDraft = null;
  }

  @override
  Future<ChatRoomDraftModel?> getDraft() async => savedDraft;

  @override
  Future<void> saveDraft(ChatRoomDraftModel draft) async {
    savedDraft = draft;
  }
}
