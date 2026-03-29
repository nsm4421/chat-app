import 'package:feature_chat_core/chat_core/data/model/chat_room_event_overview_model.dart'
    as data;
import 'package:feature_chat_core/chat_core/domain/entity/chat_room_event.dart'
    as domain;

extension ChatRoomEventOverviewModelMapper on data.ChatRoomEventOverviewModel {
  domain.ChatRoomEvent toChatRoomEvent() {
    return domain.ChatRoomEvent(
      id: id,
      chatRoomId: chatRoomId,
      userId: userId,
      type: switch (type) {
        data.ChatRoomEventTypeModel.joined => domain.ChatRoomEventType.joined,
        data.ChatRoomEventTypeModel.left => domain.ChatRoomEventType.left,
        data.ChatRoomEventTypeModel.roomDeleted =>
          domain.ChatRoomEventType.roomDeleted,
      },
      createdAt: createdAt,
      anonymousIndex: anonymousIndex,
    );
  }
}
