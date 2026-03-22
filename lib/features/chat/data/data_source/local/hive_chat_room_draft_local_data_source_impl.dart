import 'package:domodachi/core/local_storage/hive_box_name.dart';
import 'package:domodachi/features/chat/data/data_source/local/chat_room_draft_local_data_source.dart';
import 'package:domodachi/features/chat/data/model/chat_room_draft_model.dart';
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ChatRoomDraftLocalDataSource)
class HiveChatRoomDraftLocalDataSourceImpl
    implements ChatRoomDraftLocalDataSource {
  HiveChatRoomDraftLocalDataSourceImpl(this._hive);

  static const _draftKey = 'create_chat_room_draft';

  final HiveInterface _hive;

  Box<dynamic> get _box => _hive.box<dynamic>(HiveBoxName.chatCache);

  @override
  Future<ChatRoomDraftModel?> getDraft() async {
    final raw = _box.get(_draftKey);
    if (raw == null) {
      return null;
    }

    if (raw is! Map) {
      await deleteDraft();
      return null;
    }

    return ChatRoomDraftModel.fromJson(Map<String, dynamic>.from(raw));
  }

  @override
  Future<void> saveDraft(ChatRoomDraftModel draft) {
    return _box.put(_draftKey, draft.toJson());
  }

  @override
  Future<void> deleteDraft() {
    return _box.delete(_draftKey);
  }
}
