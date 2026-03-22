import 'package:domodachi/features/chat/data/model/chat_room_draft_model.dart';

abstract interface class ChatRoomDraftLocalDataSource {
  Future<ChatRoomDraftModel?> getDraft();

  Future<void> saveDraft(ChatRoomDraftModel draft);

  Future<void> deleteDraft();
}
