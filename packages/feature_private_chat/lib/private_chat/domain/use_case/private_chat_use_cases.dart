import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';
import 'package:feature_private_chat/private_chat/domain/use_case/scenario/create_or_get_private_chat_room_use_case.dart';
import 'package:feature_private_chat/private_chat/domain/use_case/scenario/fetch_my_private_chat_rooms_use_case.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class PrivateChatUseCases {
  PrivateChatUseCases(this._repository);

  final ChatRepository _repository;

  late final FetchMyPrivateChatRoomsUseCase _fetchMyPrivateChatRooms =
      FetchMyPrivateChatRoomsUseCase(_repository);
  late final CreateOrGetPrivateChatRoomUseCase _createOrGetPrivateChatRoom =
      CreateOrGetPrivateChatRoomUseCase(_repository);

  FetchMyPrivateChatRoomsUseCase get fetchMyPrivateChatRooms =>
      _fetchMyPrivateChatRooms;

  CreateOrGetPrivateChatRoomUseCase get createOrGetPrivateChatRoom =>
      _createOrGetPrivateChatRoom;
}
