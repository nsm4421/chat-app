import 'dart:io';

import 'package:feature_chat_core/chat_core/core/value_objects/chat_room_enums.dart';
import 'package:feature_chat_core/chat_core/data/model/chat_room_draft_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:infra_hive/infra_hive.dart';
import 'package:infra_hive/chat/hive_chat_room_draft_local_data_source_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDirectory;
  late HiveChatRoomDraftLocalDataSourceImpl dataSource;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'chat_room_draft_local_data_source_test',
    );
    Hive.init(tempDirectory.path);
    await Hive.openBox<dynamic>(HiveBoxName.chatCache);
    dataSource = HiveChatRoomDraftLocalDataSourceImpl(Hive);
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  group('HiveChatRoomDraftLocalDataSourceImpl', () {
    test('saves and loads draft', () async {
      final draft = ChatRoomDraftModel(
        type: ChatRoomType.group,
        title: '성수 커피 스프린트',
        description: '퇴근 후 가볍게 이야기할 분을 찾고 있어요.',
        tags: const ['coffee', 'afterwork'],
        maxParticipants: 6,
        isPublic: true,
        savedAt: DateTime(2026, 3, 22, 15),
      );

      await dataSource.saveDraft(draft);

      final result = await dataSource.getDraft();

      expect(result, draft);
    });

    test('returns null after deleting draft', () async {
      await dataSource.saveDraft(
        ChatRoomDraftModel(
          type: ChatRoomType.private,
          title: '임시 방',
          description: '',
          maxParticipants: 2,
          isPublic: false,
          savedAt: DateTime(2026, 3, 22, 15),
        ),
      );

      await dataSource.deleteDraft();

      final result = await dataSource.getDraft();

      expect(result, isNull);
    });
  });
}
