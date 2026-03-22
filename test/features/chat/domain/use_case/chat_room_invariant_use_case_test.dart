import 'package:domodachi/features/chat/core/value_objects/chat_room_enums.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room.dart';
import 'package:domodachi/features/chat/domain/failure/chat_failure.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/create_remote_chat_room_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/save_draft_chat_room_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/update_chat_room_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_chat_repository.dart';

void main() {
  group('chat room invariants', () {
    test('create blocks public private room', () async {
      final useCase = CreateRemoteChatRoomUseCase(
        FakeChatRepository(
          createRemoteChatRoomHandler:
              ({
                required status,
                required type,
                required maxParticipants,
                required isPublic,
                title,
                description,
                tags = const <String>[],
              }) async => throw UnimplementedError(),
        ),
      );

      await expectLater(
        () => useCase(
          status: ChatRoomStatus.open,
          type: ChatRoomType.private,
          maxParticipants: 2,
          isPublic: true,
        ),
        throwsA(
          isA<ChatFailure>().having(
            (error) => error.message,
            'message',
            '비공개 대화는 공개 상태로 만들 수 없어요.',
          ),
        ),
      );
    });

    test('save draft blocks invalid private capacity', () async {
      final useCase = SaveDraftChatRoomUseCase(
        FakeChatRepository(
          saveDraftChatRoomHandler:
              ({
                required type,
                required maxParticipants,
                required isPublic,
                title,
                description,
                tags = const <String>[],
              }) async => throw UnimplementedError(),
        ),
      );

      await expectLater(
        () => useCase(
          type: ChatRoomType.private,
          maxParticipants: 3,
          isPublic: false,
        ),
        throwsA(
          isA<ChatFailure>().having(
            (error) => error.message,
            'message',
            '비공개 대화는 2명으로 고정됩니다.',
          ),
        ),
      );
    });

    test('update validates final state using existing room type', () async {
      final room = ChatRoom(
        id: 'room-1',
        createdBy: 'user-1',
        type: ChatRoomType.private,
        status: ChatRoomStatus.open,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        maxParticipants: 2,
        isPublic: false,
      );

      final useCase = UpdateChatRoomUseCase(
        FakeChatRepository(
          currentRoom: room,
          updateChatRoomHandler:
              ({
                required chatRoomId,
                title,
                description,
                tags,
                maxParticipants,
                status,
                isPublic,
              }) async {},
        ),
      );

      await expectLater(
        () => useCase(chatRoomId: room.id, maxParticipants: 4),
        throwsA(
          isA<ChatFailure>().having(
            (error) => error.message,
            'message',
            '비공개 대화는 2명으로 고정됩니다.',
          ),
        ),
      );
    });
  });
}
