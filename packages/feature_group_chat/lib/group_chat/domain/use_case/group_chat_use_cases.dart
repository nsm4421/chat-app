import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/enter_chat_room_presence_use_case.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/fetch_chat_room_members_use_case.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/get_chat_room_use_case.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/leave_chat_room_presence_use_case.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/watch_chat_room_members_use_case.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/watch_chat_room_presence_events_use_case.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/watch_chat_room_presence_use_case.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/scenario/watch_deleted_chat_room_events_use_case.dart';
import 'package:feature_group_chat/group_chat/domain/use_case/scenario/create_remote_chat_room_use_case.dart';
import 'package:feature_group_chat/group_chat/domain/use_case/scenario/delete_chat_room_use_case.dart';
import 'package:feature_group_chat/group_chat/domain/use_case/scenario/delete_draft_chat_room_use_case.dart';
import 'package:feature_group_chat/group_chat/domain/use_case/scenario/delete_recent_group_chat_search_query_use_case.dart';
import 'package:feature_group_chat/group_chat/domain/use_case/scenario/fetch_discover_chat_rooms_use_case.dart';
import 'package:feature_group_chat/group_chat/domain/use_case/scenario/fetch_my_group_chat_rooms_use_case.dart';
import 'package:feature_group_chat/group_chat/domain/use_case/scenario/fetch_recent_group_chat_search_queries_use_case.dart';
import 'package:feature_group_chat/group_chat/domain/use_case/scenario/get_draft_chat_room_use_case.dart';
import 'package:feature_group_chat/group_chat/domain/use_case/scenario/join_group_chat_room_use_case.dart';
import 'package:feature_group_chat/group_chat/domain/use_case/scenario/leave_group_chat_room_use_case.dart';
import 'package:feature_group_chat/group_chat/domain/use_case/scenario/save_draft_chat_room_use_case.dart';
import 'package:feature_group_chat/group_chat/domain/use_case/scenario/save_recent_group_chat_search_query_use_case.dart';
import 'package:feature_group_chat/group_chat/domain/use_case/scenario/search_group_chat_rooms_use_case.dart';
import 'package:feature_group_chat/group_chat/domain/use_case/scenario/update_chat_room_use_case.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GroupChatUseCases {
  GroupChatUseCases(this._repository);

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
  late final GetDraftChatRoomUseCase _getDraftChatRoom =
      GetDraftChatRoomUseCase(_repository);
  late final SaveDraftChatRoomUseCase _saveDraftChatRoom =
      SaveDraftChatRoomUseCase(_repository);
  late final CreateRemoteChatRoomUseCase _createRemoteChatRoom =
      CreateRemoteChatRoomUseCase(_repository);
  late final UpdateChatRoomUseCase _updateChatRoom = UpdateChatRoomUseCase(
    _repository,
  );
  late final DeleteChatRoomUseCase _deleteChatRoom = DeleteChatRoomUseCase(
    _repository,
  );
  late final DeleteDraftChatRoomUseCase _deleteDraftChatRoom =
      DeleteDraftChatRoomUseCase(_repository);
  late final JoinGroupChatRoomUseCase _joinGroupChatRoom =
      JoinGroupChatRoomUseCase(_repository);
  late final LeaveGroupChatRoomUseCase _leaveGroupChatRoom =
      LeaveGroupChatRoomUseCase(_repository);
  late final GetChatRoomUseCase _getChatRoom = GetChatRoomUseCase(_repository);
  late final WatchDeletedChatRoomEventsUseCase _watchDeletedChatRoomEvents =
      WatchDeletedChatRoomEventsUseCase(_repository);
  late final FetchChatRoomMembersUseCase _fetchChatRoomMembers =
      FetchChatRoomMembersUseCase(_repository);
  late final EnterChatRoomPresenceUseCase _enterChatRoomPresence =
      EnterChatRoomPresenceUseCase(_repository);
  late final LeaveChatRoomPresenceUseCase _leaveChatRoomPresence =
      LeaveChatRoomPresenceUseCase(_repository);
  late final WatchChatRoomPresenceUseCase _watchChatRoomPresence =
      WatchChatRoomPresenceUseCase(_repository);
  late final WatchChatRoomPresenceEventsUseCase _watchChatRoomPresenceEvents =
      WatchChatRoomPresenceEventsUseCase(_repository);
  late final WatchChatRoomMembersUseCase _watchChatRoomMembers =
      WatchChatRoomMembersUseCase(_repository);

  FetchDiscoverChatRoomsUseCase get fetchDiscoverChatRooms =>
      _fetchDiscoverChatRooms;

  SearchGroupChatRoomsUseCase get searchGroupChatRooms => _searchGroupChatRooms;

  FetchRecentGroupChatSearchQueriesUseCase
  get fetchRecentGroupChatSearchQueries => _fetchRecentGroupChatSearchQueries;

  SaveRecentGroupChatSearchQueryUseCase get saveRecentGroupChatSearchQuery =>
      _saveRecentGroupChatSearchQuery;

  DeleteRecentGroupChatSearchQueryUseCase
  get deleteRecentGroupChatSearchQuery => _deleteRecentGroupChatSearchQuery;

  FetchMyGroupChatRoomsUseCase get fetchMyGroupChatRooms =>
      _fetchMyGroupChatRooms;

  GetDraftChatRoomUseCase get getDraftChatRoom => _getDraftChatRoom;

  SaveDraftChatRoomUseCase get saveDraftChatRoom => _saveDraftChatRoom;

  CreateRemoteChatRoomUseCase get createRemoteChatRoom => _createRemoteChatRoom;

  CreateRemoteChatRoomUseCase get createChatRoom => _createRemoteChatRoom;

  UpdateChatRoomUseCase get updateChatRoom => _updateChatRoom;

  DeleteChatRoomUseCase get deleteChatRoom => _deleteChatRoom;

  DeleteDraftChatRoomUseCase get deleteDraftChatRoom => _deleteDraftChatRoom;

  JoinGroupChatRoomUseCase get joinGroupChatRoom => _joinGroupChatRoom;

  LeaveGroupChatRoomUseCase get leaveGroupChatRoom => _leaveGroupChatRoom;

  GetChatRoomUseCase get getChatRoom => _getChatRoom;

  WatchDeletedChatRoomEventsUseCase get watchDeletedChatRoomEvents =>
      _watchDeletedChatRoomEvents;

  FetchChatRoomMembersUseCase get fetchChatRoomMembers => _fetchChatRoomMembers;

  EnterChatRoomPresenceUseCase get enterChatRoomPresence =>
      _enterChatRoomPresence;

  LeaveChatRoomPresenceUseCase get leaveChatRoomPresence =>
      _leaveChatRoomPresence;

  WatchChatRoomPresenceUseCase get watchChatRoomPresence =>
      _watchChatRoomPresence;

  WatchChatRoomPresenceEventsUseCase get watchChatRoomPresenceEvents =>
      _watchChatRoomPresenceEvents;

  WatchChatRoomMembersUseCase get watchChatRoomMembers => _watchChatRoomMembers;
}
