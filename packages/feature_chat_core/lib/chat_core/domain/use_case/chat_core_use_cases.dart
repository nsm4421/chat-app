import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/delete_chat_message_use_case.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/enter_chat_room_presence_use_case.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/fetch_chat_messages_use_case.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/fetch_chat_room_events_use_case.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/fetch_chat_room_members_use_case.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/get_chat_room_member_use_case.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/get_chat_room_use_case.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/is_chat_room_member_use_case.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/leave_chat_room_presence_use_case.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/like_chat_message_use_case.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/send_chat_message_use_case.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/unlike_chat_message_use_case.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/watch_chat_room_members_use_case.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/watch_chat_room_presence_events_use_case.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/watch_chat_room_presence_use_case.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/watch_deleted_chat_room_events_use_case.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/watch_new_chat_messages_use_case.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/watch_new_chat_room_events_use_case.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ChatCoreUseCases {
  ChatCoreUseCases(this._repository);

  final ChatRepository _repository;

  late final GetChatRoomUseCase _getChatRoom = GetChatRoomUseCase(_repository);
  late final WatchDeletedChatRoomEventsUseCase _watchDeletedChatRoomEvents =
      WatchDeletedChatRoomEventsUseCase(_repository);
  late final FetchChatMessagesUseCase _fetchChatMessages =
      FetchChatMessagesUseCase(_repository);
  late final FetchChatRoomEventsUseCase _fetchChatRoomEvents =
      FetchChatRoomEventsUseCase(_repository);
  late final WatchNewChatMessagesUseCase _watchNewChatMessages =
      WatchNewChatMessagesUseCase(_repository);
  late final WatchNewChatRoomEventsUseCase _watchNewChatRoomEvents =
      WatchNewChatRoomEventsUseCase(_repository);
  late final SendChatMessageUseCase _sendChatMessage = SendChatMessageUseCase(
    _repository,
  );
  late final LikeChatMessageUseCase _likeChatMessage = LikeChatMessageUseCase(
    _repository,
  );
  late final UnlikeChatMessageUseCase _unlikeChatMessage =
      UnlikeChatMessageUseCase(_repository);
  late final DeleteChatMessageUseCase _deleteChatMessage =
      DeleteChatMessageUseCase(_repository);
  late final EnterChatRoomPresenceUseCase _enterChatRoomPresence =
      EnterChatRoomPresenceUseCase(_repository);
  late final LeaveChatRoomPresenceUseCase _leaveChatRoomPresence =
      LeaveChatRoomPresenceUseCase(_repository);
  late final WatchChatRoomPresenceUseCase _watchChatRoomPresence =
      WatchChatRoomPresenceUseCase(_repository);
  late final WatchChatRoomPresenceEventsUseCase _watchChatRoomPresenceEvents =
      WatchChatRoomPresenceEventsUseCase(_repository);
  late final FetchChatRoomMembersUseCase _fetchChatRoomMembers =
      FetchChatRoomMembersUseCase(_repository);
  late final WatchChatRoomMembersUseCase _watchChatRoomMembers =
      WatchChatRoomMembersUseCase(_repository);
  late final GetChatRoomMemberUseCase _getChatRoomMember =
      GetChatRoomMemberUseCase(_repository);
  late final IsChatRoomMemberUseCase _isChatRoomMember =
      IsChatRoomMemberUseCase(_repository);

  GetChatRoomUseCase get getChatRoom => _getChatRoom;

  WatchDeletedChatRoomEventsUseCase get watchDeletedChatRoomEvents =>
      _watchDeletedChatRoomEvents;

  FetchChatMessagesUseCase get fetchChatMessages => _fetchChatMessages;

  FetchChatRoomEventsUseCase get fetchChatRoomEvents => _fetchChatRoomEvents;

  WatchNewChatMessagesUseCase get watchNewChatMessages => _watchNewChatMessages;

  WatchNewChatRoomEventsUseCase get watchNewChatRoomEvents =>
      _watchNewChatRoomEvents;

  SendChatMessageUseCase get sendChatMessage => _sendChatMessage;

  LikeChatMessageUseCase get likeChatMessage => _likeChatMessage;

  UnlikeChatMessageUseCase get unlikeChatMessage => _unlikeChatMessage;

  DeleteChatMessageUseCase get deleteChatMessage => _deleteChatMessage;

  EnterChatRoomPresenceUseCase get enterChatRoomPresence =>
      _enterChatRoomPresence;

  LeaveChatRoomPresenceUseCase get leaveChatRoomPresence =>
      _leaveChatRoomPresence;

  WatchChatRoomPresenceUseCase get watchChatRoomPresence =>
      _watchChatRoomPresence;

  WatchChatRoomPresenceEventsUseCase get watchChatRoomPresenceEvents =>
      _watchChatRoomPresenceEvents;

  FetchChatRoomMembersUseCase get fetchChatRoomMembers => _fetchChatRoomMembers;

  WatchChatRoomMembersUseCase get watchChatRoomMembers => _watchChatRoomMembers;

  GetChatRoomMemberUseCase get getChatRoomMember => _getChatRoomMember;

  IsChatRoomMemberUseCase get isChatRoomMember => _isChatRoomMember;
}
