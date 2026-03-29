import 'package:feature_chat_core/chat_core/data/model/chat_room_draft_model.dart';

abstract interface class ChatRoomDraftLocalDataSource {
  Future<ChatRoomDraftModel?> getDraft();

  Future<void> saveDraft(ChatRoomDraftModel draft);

  Future<void> deleteDraft();
}
