import 'package:domodachi/features/chat/data/model/chat_room_presence_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_room_presence_event_model.freezed.dart';

enum ChatRoomPresenceEventType { joined, left }

@freezed
class ChatRoomPresenceEventModel with _$ChatRoomPresenceEventModel {
  const ChatRoomPresenceEventModel({
    required this.type,
    required this.presence,
  });

  @override
  final ChatRoomPresenceEventType type;

  @override
  final ChatRoomPresenceModel presence;
}
