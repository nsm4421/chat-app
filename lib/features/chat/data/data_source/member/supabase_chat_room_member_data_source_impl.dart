import 'package:domodachi/features/chat/data/data_source/common/supabase_chat_data_source_handler.dart';
import 'package:domodachi/features/chat/data/data_source/member/chat_room_member_data_source.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: ChatRoomMemberDataSource)
class SupabaseChatRoomMemberDataSourceImpl
    with SupabaseChatDataSourceHandler
    implements ChatRoomMemberDataSource {
  SupabaseChatRoomMemberDataSourceImpl(this._client);

  static const _chatRoomMembersTable = 'chat_room_members';

  final SupabaseClient _client;

  @override
  Future<void> insert({required String chatRoomId}) {
    return guardChatRequest(() async {
      await _client.from(_chatRoomMembersTable).insert({
        'chat_room_id': chatRoomId,
        'user_id': requireCurrentUserId(_client),
      });
    });
  }

  @override
  Future<void> delete({required String chatRoomId}) {
    return guardChatRequest(() async {
      await _client
          .from(_chatRoomMembersTable)
          .delete()
          .eq('chat_room_id', chatRoomId)
          .eq('user_id', requireCurrentUserId(_client));
    });
  }
}
