import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/enter_chat_room_presence_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/create_or_get_private_chat_room_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/create_remote_chat_room_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/delete_chat_message_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/delete_chat_room_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/delete_recent_group_chat_search_query_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/delete_draft_chat_room_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/fetch_chat_room_events_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/leave_chat_room_presence_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/fetch_chat_messages_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/fetch_chat_room_members_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/fetch_discover_chat_rooms_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/fetch_recent_group_chat_search_queries_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/fetch_my_group_chat_rooms_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/fetch_my_private_chat_rooms_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/get_chat_room_member_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/join_group_chat_room_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/get_draft_chat_room_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/get_chat_room_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/is_chat_room_member_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/save_draft_chat_room_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/save_recent_group_chat_search_query_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/search_group_chat_rooms_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/send_chat_message_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/update_chat_room_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/watch_chat_room_presence_events_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/watch_chat_room_members_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/watch_chat_room_presence_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/watch_deleted_chat_room_events_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/leave_group_chat_room_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/watch_new_chat_room_events_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/watch_new_chat_messages_use_case.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ChatUseCases {
  ChatUseCases(this._repository);

  final ChatRepository _repository;

  late final FetchDiscoverChatRoomsUseCase _fetchDiscoverChatRooms =
      FetchDiscoverChatRoomsUseCase(_repository);
  late final SearchGroupChatRoomsUseCase _searchGroupChatRooms =
      SearchGroupChatRoomsUseCase(_repository);
  late final FetchRecentGroupChatSearchQueriesUseCase
  _fetchRecentGroupChatSearchQueries = FetchRecentGroupChatSearchQueriesUseCase(
    _repository,
  );
  late final SaveRecentGroupChatSearchQueryUseCase
  _saveRecentGroupChatSearchQuery = SaveRecentGroupChatSearchQueryUseCase(
    _repository,
  );
  late final DeleteRecentGroupChatSearchQueryUseCase
  _deleteRecentGroupChatSearchQuery = DeleteRecentGroupChatSearchQueryUseCase(
    _repository,
  );
  late final FetchMyGroupChatRoomsUseCase _fetchMyGroupChatRooms =
      FetchMyGroupChatRoomsUseCase(_repository);
  late final FetchMyPrivateChatRoomsUseCase _fetchMyPrivateChatRooms =
      FetchMyPrivateChatRoomsUseCase(_repository);
  late final CreateOrGetPrivateChatRoomUseCase _createOrGetPrivateChatRoom =
      CreateOrGetPrivateChatRoomUseCase(_repository);
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
  late final DeleteChatMessageUseCase _deleteChatMessage =
      DeleteChatMessageUseCase(_repository);
  late final GetDraftChatRoomUseCase _getDraftChatRoom =
      GetDraftChatRoomUseCase(_repository);
  late final SaveDraftChatRoomUseCase _saveDraftChatRoom =
      SaveDraftChatRoomUseCase(_repository);
  late final CreateRemoteChatRoomUseCase _createRemoteChatRoom =
      CreateRemoteChatRoomUseCase(_repository);
  late final CreateRemoteChatRoomUseCase _createChatRoom =
      _createRemoteChatRoom;
  late final UpdateChatRoomUseCase _updateChatRoom = UpdateChatRoomUseCase(
    _repository,
  );
  late final DeleteChatRoomUseCase _deleteChatRoom = DeleteChatRoomUseCase(
    _repository,
  );
  late final DeleteDraftChatRoomUseCase _deleteDraftChatRoom =
      DeleteDraftChatRoomUseCase(_repository);
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
  late final JoinGroupChatRoomUseCase _joinGroupChatRoom =
      JoinGroupChatRoomUseCase(_repository);
  late final LeaveGroupChatRoomUseCase _leaveGroupChatRoom =
      LeaveGroupChatRoomUseCase(_repository);

  /// Loads public group chat rooms for the group chat listing screen.
  FetchDiscoverChatRoomsUseCase get fetchDiscoverChatRooms =>
      _fetchDiscoverChatRooms;

  /// Searches public group chat rooms by title or hashtag.
  SearchGroupChatRoomsUseCase get searchGroupChatRooms => _searchGroupChatRooms;

  /// Loads recent group chat search queries from local storage.
  FetchRecentGroupChatSearchQueriesUseCase
  get fetchRecentGroupChatSearchQueries => _fetchRecentGroupChatSearchQueries;

  /// Stores a successful group chat search query locally.
  SaveRecentGroupChatSearchQueryUseCase get saveRecentGroupChatSearchQuery =>
      _saveRecentGroupChatSearchQuery;

  /// Removes a recent group chat search query from local storage.
  DeleteRecentGroupChatSearchQueryUseCase
  get deleteRecentGroupChatSearchQuery => _deleteRecentGroupChatSearchQuery;

  /// Loads joined group chat rooms, typically for "my group chats" views.
  FetchMyGroupChatRoomsUseCase get fetchMyGroupChatRooms =>
      _fetchMyGroupChatRooms;

  /// Loads joined private chats for inbox/private chat lists.
  FetchMyPrivateChatRoomsUseCase get fetchMyPrivateChatRooms =>
      _fetchMyPrivateChatRooms;

  /// Opens a DM room with the given user, reusing the existing private room.
  CreateOrGetPrivateChatRoomUseCase get createOrGetPrivateChatRoom =>
      _createOrGetPrivateChatRoom;

  /// Fetches the latest snapshot of a single chat room.
  GetChatRoomUseCase get getChatRoom => _getChatRoom;

  /// Watches deleted room events so list/detail UIs can react consistently.
  WatchDeletedChatRoomEventsUseCase get watchDeletedChatRoomEvents =>
      _watchDeletedChatRoomEvents;

  /// Loads a paged batch of historical chat messages for room entry.
  FetchChatMessagesUseCase get fetchChatMessages => _fetchChatMessages;

  /// Loads a paged batch of historical room events for timeline rendering.
  FetchChatRoomEventsUseCase get fetchChatRoomEvents => _fetchChatRoomEvents;

  /// Subscribes to newly arriving chat messages after initial load.
  WatchNewChatMessagesUseCase get watchNewChatMessages => _watchNewChatMessages;

  /// Subscribes to newly arriving room events after initial load.
  WatchNewChatRoomEventsUseCase get watchNewChatRoomEvents =>
      _watchNewChatRoomEvents;

  /// Sends a text chat message to the current room.
  SendChatMessageUseCase get sendChatMessage => _sendChatMessage;

  /// Soft-deletes a previously sent chat message.
  DeleteChatMessageUseCase get deleteChatMessage => _deleteChatMessage;

  /// Restores an in-progress room draft from local storage.
  GetDraftChatRoomUseCase get getDraftChatRoom => _getDraftChatRoom;

  /// Saves the current room form as a local draft.
  SaveDraftChatRoomUseCase get saveDraftChatRoom => _saveDraftChatRoom;

  /// Creates and persists a chat room on the backend.
  CreateRemoteChatRoomUseCase get createRemoteChatRoom => _createRemoteChatRoom;

  /// Alias for createRemoteChatRoom kept for simpler presentation usage.
  CreateRemoteChatRoomUseCase get createChatRoom => _createChatRoom;

  /// Updates editable metadata of an existing chat room.
  UpdateChatRoomUseCase get updateChatRoom => _updateChatRoom;

  /// Soft-deletes the given chat room.
  DeleteChatRoomUseCase get deleteChatRoom => _deleteChatRoom;

  /// Removes a locally saved room draft.
  DeleteDraftChatRoomUseCase get deleteDraftChatRoom => _deleteDraftChatRoom;

  /// Marks the current user as present in the room.
  EnterChatRoomPresenceUseCase get enterChatRoomPresence =>
      _enterChatRoomPresence;

  /// Removes the current user's presence from the room.
  LeaveChatRoomPresenceUseCase get leaveChatRoomPresence =>
      _leaveChatRoomPresence;

  /// Watches the full in-room presence snapshot.
  WatchChatRoomPresenceUseCase get watchChatRoomPresence =>
      _watchChatRoomPresence;

  /// Watches enter/leave presence events for lightweight system feedback.
  WatchChatRoomPresenceEventsUseCase get watchChatRoomPresenceEvents =>
      _watchChatRoomPresenceEvents;

  /// Loads a page of room members for headers/member sheets.
  FetchChatRoomMembersUseCase get fetchChatRoomMembers => _fetchChatRoomMembers;

  /// Watches the current member list in realtime.
  WatchChatRoomMembersUseCase get watchChatRoomMembers => _watchChatRoomMembers;

  /// Loads a single member record enriched with profile fields.
  GetChatRoomMemberUseCase get getChatRoomMember => _getChatRoomMember;

  /// Checks whether a user is currently a member of a room.
  IsChatRoomMemberUseCase get isChatRoomMember => _isChatRoomMember;

  /// Joins a public group room and registers presence.
  JoinGroupChatRoomUseCase get joinGroupChatRoom => _joinGroupChatRoom;

  /// Leaves a group room and clears presence.
  LeaveGroupChatRoomUseCase get leaveGroupChatRoom => _leaveGroupChatRoom;
}
