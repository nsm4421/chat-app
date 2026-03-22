import 'package:domodachi/core/extensions/string_extension.dart';
import 'package:domodachi/features/chat/domain/validation/chat_room_field_rules.dart';

final class ChatRoomInputValidator {
  const ChatRoomInputValidator._();

  static String? title(String? value, {required bool isPrivate}) {
    final title = value ?? '';

    if (isPrivate && title.trim().isEmpty) {
      return null;
    }

    final requiredMessage = title.validateRequired(message: '방 제목을 입력해 주세요.');
    if (requiredMessage != null) {
      return requiredMessage;
    }

    final minLengthMessage = title.validateMinLength(
      ChatRoomFieldRules.titleMinLength,
      message: '방 제목은 ${ChatRoomFieldRules.titleMinLength}자 이상이어야 합니다.',
    );
    if (minLengthMessage != null) {
      return minLengthMessage;
    }

    if (title.trim().length > ChatRoomFieldRules.titleMaxLength) {
      return '방 제목은 ${ChatRoomFieldRules.titleMaxLength}자 이하여야 합니다.';
    }

    return null;
  }

  static String? description(String? value, {required bool isPrivate}) {
    final description = value ?? '';

    if (isPrivate && description.trim().isEmpty) {
      return null;
    }

    final requiredMessage = description.validateRequired(
      message: '방 소개를 입력해 주세요.',
    );
    if (requiredMessage != null) {
      return requiredMessage;
    }

    final minLengthMessage = description.validateMinLength(
      ChatRoomFieldRules.descriptionMinLength,
      message: '방 소개는 ${ChatRoomFieldRules.descriptionMinLength}자 이상이어야 합니다.',
    );
    if (minLengthMessage != null) {
      return minLengthMessage;
    }

    if (description.trim().length > ChatRoomFieldRules.descriptionMaxLength) {
      return '방 소개는 ${ChatRoomFieldRules.descriptionMaxLength}자 이하여야 합니다.';
    }

    return null;
  }

  static String? maxParticipants(int? value, {required bool isPrivate}) {
    if (value == null) {
      return '참여 인원을 입력해 주세요.';
    }

    if (isPrivate) {
      if (value != ChatRoomFieldRules.privateParticipantCount) {
        return '개인 채팅은 ${ChatRoomFieldRules.privateParticipantCount}명으로 고정됩니다.';
      }
      return null;
    }

    if (value < ChatRoomFieldRules.groupMinParticipants ||
        value > ChatRoomFieldRules.groupMaxParticipants) {
      return '그룹 채팅 인원은 ${ChatRoomFieldRules.groupMinParticipants}명 이상 '
          '${ChatRoomFieldRules.groupMaxParticipants}명 이하여야 합니다.';
    }

    return null;
  }

  static String? tags(List<String> values) {
    final trimmedValues = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    final normalizedValues = trimmedValues
        .map((value) => value.toLowerCase())
        .toList(growable: false);

    if (trimmedValues.length > ChatRoomFieldRules.tagMaxCount) {
      return '태그는 최대 ${ChatRoomFieldRules.tagMaxCount}개까지 입력할 수 있습니다.';
    }

    if (normalizedValues.toSet().length != normalizedValues.length) {
      return '중복된 태그는 추가할 수 없습니다.';
    }

    final hasTooLongTag = trimmedValues.any(
      (value) => value.length > ChatRoomFieldRules.tagMaxLength,
    );
    if (hasTooLongTag) {
      return '태그 한 개는 ${ChatRoomFieldRules.tagMaxLength}자 이하여야 합니다.';
    }

    return null;
  }
}
