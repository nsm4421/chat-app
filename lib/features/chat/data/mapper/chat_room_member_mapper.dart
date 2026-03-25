import 'package:domodachi/features/chat/data/model/chat_room_member_overview_model.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room_member.dart';

extension ChatRoomMemberOverviewModelMapper on ChatRoomMemberOverviewModel {
  ChatRoomMember toChatRoomMember() {
    return ChatRoomMember(
      chatRoomId: chatRoomId,
      userId: userId,
      isHost: isHost,
      joinedAt: joinedAt,
      anonymousIndex: anonymousIndex,
      displayName: displayName,
      username: username,
      avatarUrl: avatarUrl,
    );
  }
}
