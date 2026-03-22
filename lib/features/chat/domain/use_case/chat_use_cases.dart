import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/create_remote_chat_room_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/delete_chat_room_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/delete_draft_chat_room_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/fetch_discover_chat_rooms_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/fetch_my_group_chat_rooms_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/fetch_my_private_chat_rooms_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/get_draft_chat_room_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/get_chat_room_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/join_chat_room_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/leave_chat_room_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/save_draft_chat_room_use_case.dart';
import 'package:domodachi/features/chat/domain/use_case/scenario/update_chat_room_use_case.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ChatUseCases {
  ChatUseCases(this._repository);

  final ChatRepository _repository;

  late final FetchDiscoverChatRoomsUseCase _fetchDiscoverChatRooms =
      FetchDiscoverChatRoomsUseCase(_repository);
  late final FetchMyGroupChatRoomsUseCase _fetchMyGroupChatRooms =
      FetchMyGroupChatRoomsUseCase(_repository);
  late final FetchMyPrivateChatRoomsUseCase _fetchMyPrivateChatRooms =
      FetchMyPrivateChatRoomsUseCase(_repository);
  late final GetChatRoomUseCase _getChatRoom = GetChatRoomUseCase(_repository);
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
  late final JoinChatRoomUseCase _joinChatRoom = JoinChatRoomUseCase(
    _repository,
  );
  late final LeaveChatRoomUseCase _leaveChatRoom = LeaveChatRoomUseCase(
    _repository,
  );
  late final DeleteChatRoomUseCase _deleteChatRoom = DeleteChatRoomUseCase(
    _repository,
  );
  late final DeleteDraftChatRoomUseCase _deleteDraftChatRoom =
      DeleteDraftChatRoomUseCase(_repository);

  FetchDiscoverChatRoomsUseCase get fetchDiscoverChatRooms =>
      _fetchDiscoverChatRooms;
  FetchMyGroupChatRoomsUseCase get fetchMyGroupChatRooms =>
      _fetchMyGroupChatRooms;
  FetchMyPrivateChatRoomsUseCase get fetchMyPrivateChatRooms =>
      _fetchMyPrivateChatRooms;
  GetChatRoomUseCase get getChatRoom => _getChatRoom;
  GetDraftChatRoomUseCase get getDraftChatRoom => _getDraftChatRoom;
  SaveDraftChatRoomUseCase get saveDraftChatRoom => _saveDraftChatRoom;
  CreateRemoteChatRoomUseCase get createRemoteChatRoom => _createRemoteChatRoom;
  CreateRemoteChatRoomUseCase get createChatRoom => _createChatRoom;
  UpdateChatRoomUseCase get updateChatRoom => _updateChatRoom;
  JoinChatRoomUseCase get joinChatRoom => _joinChatRoom;
  LeaveChatRoomUseCase get leaveChatRoom => _leaveChatRoom;
  DeleteChatRoomUseCase get deleteChatRoom => _deleteChatRoom;
  DeleteDraftChatRoomUseCase get deleteDraftChatRoom => _deleteDraftChatRoom;
}
