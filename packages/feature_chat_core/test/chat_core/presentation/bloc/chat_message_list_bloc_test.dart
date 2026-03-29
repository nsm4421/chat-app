import 'package:feature_chat_core/chat_core/domain/entity/chat_message.dart';
import 'package:feature_chat_core/chat_core/domain/entity/chat_room_event.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/chat_core_use_cases.dart';
import 'package:feature_chat_core/chat_core/presentation/bloc/room/chat_message_list_bloc.dart';
import 'package:feature_chat_core/chat_core/presentation/bloc/room/chat_message_list_state.dart';
import 'package:feature_chat_core/chat_core/presentation/bloc/room/chat_timeline_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_chat_repository.dart';

void main() {
  group('ChatMessageListBloc', () {
    test(
      'merges messages and room events into a single newest-first timeline',
      () async {
        final repository = FakeChatRepository()
          ..chatMessages = [
            ChatMessage(
              id: 'message-1',
              chatRoomId: 'room-id',
              senderId: 'user-1',
              content: '최근 메시지',
              createdAt: DateTime(2026, 3, 25, 12, 0),
              anonymousIndex: 1,
            ),
            ChatMessage(
              id: 'message-2',
              chatRoomId: 'room-id',
              senderId: 'user-2',
              content: '이전 메시지',
              createdAt: DateTime(2026, 3, 25, 11, 0),
              anonymousIndex: 2,
            ),
          ]
          ..chatRoomEvents = [
            ChatRoomEvent(
              id: 'event-1',
              chatRoomId: 'room-id',
              userId: 'user-3',
              type: ChatRoomEventType.joined,
              createdAt: DateTime(2026, 3, 25, 11, 30),
              anonymousIndex: 3,
            ),
          ];

        final bloc = ChatMessageListBloc(ChatCoreUseCases(repository), 'room-id');
        await pumpEventQueue(times: 20);

        expect(bloc.state.timelineItems, hasLength(3));
        expect(
          bloc.state.timelineItems.map((item) => item.createdAt).toList(),
          [
            DateTime(2026, 3, 25, 12, 0),
            DateTime(2026, 3, 25, 11, 30),
            DateTime(2026, 3, 25, 11, 0),
          ],
        );
        expect(bloc.state.timelineItems[1], isA<ChatTimelineEntryEvent>());

        await bloc.close();
      },
    );

    test('prepends realtime room events into the timeline', () async {
      final repository = FakeChatRepository()
        ..watchNewChatRoomEventsHandler = (_) => Stream.value(
          ChatRoomEvent(
            id: 'event-1',
            chatRoomId: 'room-id',
            userId: 'user-3',
            type: ChatRoomEventType.left,
            createdAt: DateTime(2026, 3, 25, 12, 30),
            anonymousIndex: 3,
          ),
        );

      final bloc = ChatMessageListBloc(ChatCoreUseCases(repository), 'room-id');
      await pumpEventQueue(times: 20);

      expect(bloc.state.timelineItems, hasLength(1));
      expect(bloc.state.timelineItems.first, isA<ChatTimelineEntryEvent>());
      expect(bloc.state.events.first.type, ChatRoomEventType.left);

      await bloc.close();
    });
  });
}
