import 'package:domodachi/features/chat/core/value_objects/chat_room_enums.dart';
import 'package:domodachi/features/chat/data/data_source/event/chat_room_event_data_source.dart';
import 'package:domodachi/features/chat/data/data_source/local/chat_room_draft_local_data_source.dart';
import 'package:domodachi/features/chat/data/data_source/message/chat_message_data_source.dart';
import 'package:domodachi/features/chat/data/data_source/member/chat_room_member_data_source.dart';
import 'package:domodachi/features/chat/data/data_source/presence/chat_room_presence_data_source.dart';
import 'package:domodachi/features/chat/data/data_source/room/chat_room_data_source.dart';
import 'package:domodachi/features/chat/data/model/chat_message_model.dart';
import 'package:domodachi/features/chat/data/model/chat_message_overview_model.dart';
import 'package:domodachi/features/chat/data/model/chat_room_event_overview_model.dart';
import 'package:domodachi/features/chat/data/model/chat_room_member_overview_model.dart';
import 'package:domodachi/features/chat/data/model/chat_room_presence_event_model.dart';
import 'package:domodachi/features/chat/data/model/chat_room_presence_model.dart';
import 'package:domodachi/features/chat/data/model/chat_room_draft_model.dart';
import 'package:domodachi/features/chat/data/model/chat_room_model.dart';
import 'package:domodachi/features/chat/data/repository/chat_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeChatRoomDataSource chatRoomDataSource;
  late _FakeChatRoomDraftLocalDataSource chatRoomDraftLocalDataSource;
  late _FakeChatRoomEventDataSource chatRoomEventDataSource;
  late _FakeChatMessageDataSource chatMessageDataSource;
  late _FakeChatRoomPresenceDataSource chatRoomPresenceDataSource;
  late _FakeChatRoomMemberDataSource chatRoomMemberDataSource;
  late ChatRepositoryImpl repository;

  setUp(() {
    chatRoomDataSource = _FakeChatRoomDataSource();
    chatRoomDraftLocalDataSource = _FakeChatRoomDraftLocalDataSource();
    chatRoomEventDataSource = _FakeChatRoomEventDataSource();
    chatMessageDataSource = _FakeChatMessageDataSource();
    chatRoomPresenceDataSource = _FakeChatRoomPresenceDataSource();
    chatRoomMemberDataSource = _FakeChatRoomMemberDataSource();
    repository = ChatRepositoryImpl(
      chatRoomDataSource,
      chatRoomDraftLocalDataSource,
      chatRoomEventDataSource,
      chatMessageDataSource,
      chatRoomPresenceDataSource,
      chatRoomMemberDataSource,
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

  group('messages', () {
    test('maps fetched overview messages into domain entities', () async {
      final messages = await repository.fetchChatMessages(
        chatRoomId: 'room-id',
      );

      expect(messages, hasLength(1));
      expect(messages.first.senderDisplayName, 'Mina');
      expect(messages.first.content, '안녕하세요');
    });

    test('sends message through message datasource', () async {
      final message = await repository.sendChatMessage(
        chatRoomId: 'room-id',
        content: '반가워요',
      );

      expect(chatMessageDataSource.insertCallCount, 1);
      expect(message.content, '반가워요');
    });

    test('maps presence stream into domain entities', () async {
      final presences = await repository
          .watchChatRoomPresence(chatRoomId: 'room-id')
          .first;

      expect(presences, hasLength(1));
      expect(presences.first.userId, 'user-1');
      expect(presences.first.displayName, 'Mina');
    });

    test('forwards enter presence to presence datasource', () async {
      await repository.enterChatRoomPresence('room-id');

      expect(chatRoomPresenceDataSource.enterCallCount, 1);
      expect(chatRoomPresenceDataSource.lastEnteredRoomId, 'room-id');
    });
  });

  group('events', () {
    test('maps fetched room events into domain entities', () async {
      final events = await repository.fetchChatRoomEvents(
        chatRoomId: 'room-id',
      );

      expect(events, hasLength(1));
      expect(events.first.type.name, 'joined');
      expect(events.first.anonymousIndex, 3);
    });

    test('maps realtime room events into domain entities', () async {
      final event = await repository
          .watchNewChatRoomEvents(chatRoomId: 'room-id')
          .first;

      expect(event.type.name, 'joined');
      expect(event.chatRoomId, 'room-id');
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

final class _FakeChatMessageDataSource implements ChatMessageDataSource {
  int insertCallCount = 0;

  @override
  Future<Iterable<ChatMessageOverviewModel>> fetchMessages({
    required String chatRoomId,
    int limit = 50,
    String? cursor,
  }) async {
    return [
      ChatMessageOverviewModel(
        id: 'message-id',
        chatRoomId: chatRoomId,
        senderId: 'user-1',
        content: '안녕하세요',
        createdAt: DateTime(2026, 3, 22, 18),
        senderDisplayName: 'Mina',
      ),
    ];
  }

  @override
  Future<ChatMessageModel> insert({
    required String chatRoomId,
    required String content,
  }) async {
    insertCallCount += 1;
    return ChatMessageModel(
      id: 'new-message-id',
      chatRoomId: chatRoomId,
      senderId: 'user-1',
      content: content,
      createdAt: DateTime(2026, 3, 22, 18, 1),
    );
  }

  @override
  Future<void> softDelete({required String chatMessageId}) async {}

  @override
  Stream<ChatMessageOverviewModel> watchNewMessages({
    required String chatRoomId,
  }) {
    return const Stream.empty();
  }
}

final class _FakeChatRoomEventDataSource implements ChatRoomEventDataSource {
  @override
  Future<Iterable<ChatRoomEventOverviewModel>> fetchEvents({
    required String chatRoomId,
    int limit = 50,
    String? cursor,
  }) async {
    return [
      ChatRoomEventOverviewModel(
        id: 'event-id',
        chatRoomId: chatRoomId,
        userId: 'user-3',
        type: ChatRoomEventTypeModel.joined,
        createdAt: DateTime(2026, 3, 25, 17),
        anonymousIndex: 3,
      ),
    ];
  }

  @override
  Stream<ChatRoomEventOverviewModel> watchNewEvents({
    required String chatRoomId,
  }) {
    return Stream<ChatRoomEventOverviewModel>.value(
      ChatRoomEventOverviewModel(
        id: 'event-stream-id',
        chatRoomId: chatRoomId,
        userId: 'user-3',
        type: ChatRoomEventTypeModel.joined,
        createdAt: DateTime(2026, 3, 25, 17, 1),
        anonymousIndex: 3,
      ),
    );
  }

  @override
  Stream<ChatRoomEventOverviewModel> watchDeletedRoomEvents() {
    return const Stream.empty();
  }
}

final class _FakeChatRoomPresenceDataSource
    implements ChatRoomPresenceDataSource {
  int enterCallCount = 0;
  String? lastEnteredRoomId;

  @override
  Future<void> enter(String chatRoomId) async {
    enterCallCount += 1;
    lastEnteredRoomId = chatRoomId;
  }

  @override
  Future<void> leave(String chatRoomId) async {}

  @override
  Stream<List<ChatRoomPresenceModel>> watchPresence(String chatRoomId) {
    return Stream<List<ChatRoomPresenceModel>>.value([
      ChatRoomPresenceModel(
        userId: 'user-1',
        presenceRef: 'presence-1',
        displayName: 'Mina',
        onlineAt: DateTime(2026, 3, 23, 10),
      ),
    ]);
  }

  @override
  Stream<ChatRoomPresenceEventModel> watchPresenceEvents(String chatRoomId) {
    return Stream<ChatRoomPresenceEventModel>.value(
      ChatRoomPresenceEventModel(
        type: ChatRoomPresenceEventType.joined,
        presence: ChatRoomPresenceModel(
          userId: 'user-1',
          presenceRef: 'presence-1',
          displayName: 'Mina',
        ),
      ),
    );
  }
}

final class _FakeChatRoomMemberDataSource implements ChatRoomMemberDataSource {
  @override
  Future<void> join(String chatRoomId) async {}

  @override
  Future<void> leave(String chatRoomId) async {}

  @override
  Future<bool> isMember({
    required String chatRoomId,
    required String userId,
  }) async => false;

  @override
  Future<ChatRoomMemberOverviewModel?> getMember({
    required String chatRoomId,
    required String userId,
  }) async => null;

  @override
  Future<Iterable<ChatRoomMemberOverviewModel>> fetchMembers({
    required String chatRoomId,
    int limit = 30,
    String? cursor,
  }) async => const <ChatRoomMemberOverviewModel>[];

  @override
  Stream<List<ChatRoomMemberOverviewModel>> watchMembers({
    required String chatRoomId,
  }) {
    return const Stream.empty();
  }
}
