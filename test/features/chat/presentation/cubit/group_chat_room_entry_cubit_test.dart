import 'package:domodachi/features/chat/core/value_objects/chat_room_enums.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room.dart';
import 'package:domodachi/features/chat/domain/use_case/chat_use_cases.dart';
import 'package:domodachi/features/chat/presentation/cubit/room/group_chat_room_entry_cubit.dart';
import 'package:domodachi/features/chat/presentation/cubit/room/group_chat_room_entry_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_chat_repository.dart';

void main() {
  group('GroupChatRoomEntryCubit', () {
    late FakeChatRepository repository;
    late ChatUseCases chatUseCases;
    late GroupChatRoomEntryCubit cubit;

    setUp(() {
      repository = FakeChatRepository();
      chatUseCases = ChatUseCases(repository);
      cubit = GroupChatRoomEntryCubit(chatUseCases);
    });

    tearDown(() async {
      await cubit.close();
    });

    test('public open room resolves to preview state', () async {
      repository.currentRoom = _room();

      await cubit.load('room-1');

      expect(cubit.state.status, GroupChatRoomEntryStatus.preview);
    });

    test('full room resolves to full state', () async {
      repository.currentRoom = _room(
        status: ChatRoomStatus.full,
        memberCount: 8,
      );

      await cubit.load('room-1');

      expect(cubit.state.status, GroupChatRoomEntryStatus.full);
    });

    test('closed room resolves to closed state', () async {
      repository.currentRoom = _room(status: ChatRoomStatus.closed);

      await cubit.load('room-1');

      expect(cubit.state.status, GroupChatRoomEntryStatus.closed);
    });

    test('private room resolves to restricted state', () async {
      repository.currentRoom = _room(isPublic: false);

      await cubit.load('room-1');

      expect(cubit.state.status, GroupChatRoomEntryStatus.restricted);
    });

    test('missing room resolves to notFound state', () async {
      repository.currentRoom = null;

      await cubit.load('room-1');

      expect(cubit.state.status, GroupChatRoomEntryStatus.notFound);
    });

    test('join transitions preview to joined state', () async {
      repository.currentRoom = _room();

      await cubit.load('room-1');
      await cubit.join();

      expect(cubit.state.status, GroupChatRoomEntryStatus.joined);
      expect(cubit.state.room?.id, 'room-1');
    });
  });
}

ChatRoom _room({
  ChatRoomStatus status = ChatRoomStatus.open,
  bool isPublic = true,
  int memberCount = 3,
}) {
  return ChatRoom(
    id: 'room-1',
    createdBy: 'user-1',
    type: ChatRoomType.group,
    status: status,
    createdAt: DateTime(2026, 3, 22, 9),
    updatedAt: DateTime(2026, 3, 22, 9),
    title: 'Seongsu coffee',
    description: '같이 커피 마시고 이야기할 사람 구해요.',
    maxParticipants: 8,
    isPublic: isPublic,
    memberCount: memberCount,
  );
}
