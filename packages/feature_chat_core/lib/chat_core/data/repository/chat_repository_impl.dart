import 'dart:async';

import 'package:feature_chat_core/chat_core/core/value_objects/chat_room_enums.dart';
import 'package:feature_chat_core/chat_core/data/data_source/event/chat_room_event_data_source.dart';
import 'package:feature_chat_core/chat_core/data/data_source/local/chat_room_draft_local_data_source.dart';
import 'package:feature_chat_core/chat_core/data/data_source/local/group_chat_search_local_data_source.dart';
import 'package:feature_chat_core/chat_core/data/data_source/message/chat_message_data_source.dart';
import 'package:feature_chat_core/chat_core/data/data_source/member/chat_room_member_data_source.dart';
import 'package:feature_chat_core/chat_core/data/data_source/presence/chat_room_presence_data_source.dart';
import 'package:feature_chat_core/chat_core/data/data_source/room/chat_room_data_source.dart';
import 'package:feature_chat_core/chat_core/data/exception/chat_data_exception.dart';
import 'package:feature_chat_core/chat_core/data/mapper/chat_room_event_mapper.dart';
import 'package:feature_chat_core/chat_core/data/mapper/chat_message_mapper.dart';
import 'package:feature_chat_core/chat_core/data/mapper/chat_room_member_mapper.dart';
import 'package:feature_chat_core/chat_core/data/mapper/chat_room_presence_mapper.dart';
import 'package:feature_chat_core/chat_core/data/mapper/chat_room_mapper.dart';
import 'package:feature_chat_core/chat_core/data/model/chat_room_draft_model.dart';
import 'package:feature_chat_core/chat_core/data/repository/chat_repository_error_handler.dart';
import 'package:feature_chat_core/chat_core/domain/entity/chat_message.dart';
import 'package:feature_chat_core/chat_core/domain/entity/chat_room_event.dart';
import 'package:feature_chat_core/chat_core/domain/entity/chat_room_member.dart';
import 'package:feature_chat_core/chat_core/domain/entity/chat_room_presence.dart';
import 'package:feature_chat_core/chat_core/domain/entity/chat_room.dart';
import 'package:feature_chat_core/chat_core/domain/failure/chat_failure.dart';
import 'package:feature_chat_core/chat_core/domain/repository/chat_repository.dart';
import 'package:injectable/injectable.dart';

part 'chat_repository_event_mixin.dart';
part 'chat_repository_message_mixin.dart';
part 'chat_repository_presence_mixin.dart';
part 'chat_repository_room_mixin.dart';
part 'chat_repository_member_mixin.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl
    with
        ChatRepositoryErrorHandler,
        _ChatRoomRepositoryMixin,
        _ChatEventRepositoryMixin,
        _ChatMessageRepositoryMixin,
        _ChatPresenceRepositoryMixin,
        _ChatMemberRepositoryMixin
    implements ChatRepository {
  ChatRepositoryImpl(
    this._chatRoomDataSource,
    this._chatRoomDraftLocalDataSource,
    this._groupChatSearchLocalDataSource,
    this._chatRoomEventDataSource,
    this._chatMessageDataSource,
    this._chatRoomPresenceDataSource,
    this._chatRoomMemberDataSource,
  );

  @override
  final ChatRoomDataSource _chatRoomDataSource;
  @override
  final ChatRoomDraftLocalDataSource _chatRoomDraftLocalDataSource;
  @override
  final GroupChatSearchLocalDataSource _groupChatSearchLocalDataSource;
  @override
  final ChatRoomEventDataSource _chatRoomEventDataSource;
  @override
  final ChatMessageDataSource _chatMessageDataSource;
  @override
  final ChatRoomPresenceDataSource _chatRoomPresenceDataSource;
  @override
  final ChatRoomMemberDataSource _chatRoomMemberDataSource;
}
