import 'package:domodachi/features/chat/data/model/chat_room_member_overview_model.dart';

abstract interface class ChatRoomMemberDataSource {
  /// Adds the member row for the given room.
  ///
  /// Note: actual authorization is enforced by Supabase RLS policies.
  Future<void> join(String chatRoomId);

  /// Removes the member row for the given room (self leave or host removal).
  ///
  /// Note: actual authorization is enforced by Supabase RLS policies.
  Future<void> leave(String chatRoomId);

  /// Checks whether `userId` is a member of the room.
  Future<bool> isMember({
    required String chatRoomId,
    required String userId,
  });

  /// Fetches a room member enriched with profile fields.
  Future<ChatRoomMemberOverviewModel?> getMember({
    required String chatRoomId,
    required String userId,
  });

  /// Returns a page of members for the room ordered by `joined_at` (desc).
  Future<Iterable<ChatRoomMemberOverviewModel>> fetchMembers({
    required String chatRoomId,
    int limit = 30,
    String? cursor,
  });

  /// Emits the current member list for the room in realtime.
  Stream<List<ChatRoomMemberOverviewModel>> watchMembers({
    required String chatRoomId,
  });
}

