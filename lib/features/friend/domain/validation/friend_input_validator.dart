import 'package:domodachi/features/friend/domain/validation/friend_field_rules.dart';

final class FriendInputValidator {
  const FriendInputValidator._();

  static String? requestMessage(String? value) {
    final message = value?.trim() ?? '';
    if (message.isEmpty) {
      return null;
    }

    if (message.length > FriendFieldRules.requestMessageMaxLength) {
      return '친구 요청 메시지는 ${FriendFieldRules.requestMessageMaxLength}자 이하여야 합니다.';
    }

    return null;
  }

  static String? searchQuery(String? value) {
    final query = value?.trim() ?? '';
    if (query.isEmpty) {
      return '검색어를 입력해 주세요.';
    }

    return null;
  }
}
