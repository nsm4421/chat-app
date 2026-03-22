abstract interface class ChatRoomMemberDataSource {
  Future<void> insert({required String chatRoomId});

  Future<void> delete({required String chatRoomId});
}
