import 'package:feature_chat_core/chat_core/core/value_objects/chat_room_enums.dart';
import 'package:feature_chat_core/chat_core/domain/failure/chat_failure.dart';
import 'package:feature_group_chat/group_chat/domain/validation/chat_room_field_rules.dart';

final class ChatRoomInvariantValidator {
  const ChatRoomInvariantValidator._();

  /// Keep private/group rules centralized so the app can use one ChatRoom model
  /// without splitting it into separate subtypes.
  static void validateOrThrow({
    required ChatRoomType type,
    required int maxParticipants,
    required bool isPublic,
  }) {
    if (type == ChatRoomType.private) {
      if (maxParticipants != ChatRoomFieldRules.privateParticipantCount) {
        throw ChatFailure(
          '비공개 대화는 ${ChatRoomFieldRules.privateParticipantCount}명으로 고정됩니다.',
        );
      }

      if (isPublic) {
        throw const ChatFailure('비공개 대화는 공개 상태로 만들 수 없어요.');
      }

      return;
    }

    if (maxParticipants < ChatRoomFieldRules.groupMinParticipants ||
        maxParticipants > ChatRoomFieldRules.groupMaxParticipants) {
      throw ChatFailure(
        '그룹 채팅 인원은 ${ChatRoomFieldRules.groupMinParticipants}명 이상 '
        '${ChatRoomFieldRules.groupMaxParticipants}명 이하여야 합니다.',
      );
    }
  }
}
