import 'dart:async';

import 'package:domodachi/features/chat/core/value_objects/chat_room_enums.dart';
import 'package:domodachi/features/chat/data/data_source/local/chat_room_draft_local_data_source.dart';
import 'package:domodachi/features/chat/data/data_source/message/chat_message_data_source.dart';
import 'package:domodachi/features/chat/data/data_source/presence/chat_room_presence_data_source.dart';
import 'package:domodachi/features/chat/data/data_source/room/chat_room_data_source.dart';
import 'package:domodachi/features/chat/data/exception/chat_data_exception.dart';
import 'package:domodachi/features/chat/data/mapper/chat_message_mapper.dart';
import 'package:domodachi/features/chat/data/mapper/chat_room_presence_mapper.dart';
import 'package:domodachi/features/chat/data/mapper/chat_room_mapper.dart';
import 'package:domodachi/features/chat/data/model/chat_room_draft_model.dart';
import 'package:domodachi/features/chat/data/repository/chat_repository_error_handler.dart';
import 'package:domodachi/features/chat/domain/entity/chat_message.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room_presence.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room.dart';
import 'package:domodachi/features/chat/domain/failure/chat_failure.dart';
import 'package:domodachi/features/chat/domain/repository/chat_repository.dart';
import 'package:injectable/injectable.dart';

part 'chat_repository_message_mixin.dart';
part 'chat_repository_presence_mixin.dart';
part 'chat_repository_room_mixin.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl
    with
        ChatRepositoryErrorHandler,
        _ChatRoomRepositoryMixin,
        _ChatMessageRepositoryMixin,
        _ChatPresenceRepositoryMixin
    implements ChatRepository {
  ChatRepositoryImpl(
    this._chatRoomDataSource,
    this._chatRoomDraftLocalDataSource,
    this._chatMessageDataSource,
    this._chatRoomPresenceDataSource,
  );

  @override
  final ChatRoomDataSource _chatRoomDataSource;
  @override
  final ChatRoomDraftLocalDataSource _chatRoomDraftLocalDataSource;
  @override
  final ChatMessageDataSource _chatMessageDataSource;
  @override
  final ChatRoomPresenceDataSource _chatRoomPresenceDataSource;
}
