import 'package:domodachi/features/chat/data/model/chat_room_presence_event_model.dart'
    as data;
import 'package:domodachi/features/chat/data/model/chat_room_presence_model.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room_presence.dart'
    as domain;

extension ChatRoomPresenceModelMapper on ChatRoomPresenceModel {
  domain.ChatRoomPresence toChatRoomPresence() {
    return domain.ChatRoomPresence(
      userId: userId,
      presenceRef: presenceRef,
      displayName: displayName,
      avatarUrl: avatarUrl,
      onlineAt: onlineAt,
    );
  }
}

extension ChatRoomPresenceEventModelMapper on data.ChatRoomPresenceEventModel {
  domain.ChatRoomPresenceEvent toChatRoomPresenceEvent() {
    return domain.ChatRoomPresenceEvent(
      type: switch (type) {
        data.ChatRoomPresenceEventType.joined =>
          domain.ChatRoomPresenceEventType.joined,
        data.ChatRoomPresenceEventType.left =>
          domain.ChatRoomPresenceEventType.left,
      },
      presence: presence.toChatRoomPresence(),
    );
  }
}
