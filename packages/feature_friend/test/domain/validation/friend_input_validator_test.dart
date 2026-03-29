import 'package:feature_friend/domain/validation/friend_field_rules.dart';
import 'package:feature_friend/domain/validation/friend_input_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FriendInputValidator.requestMessage', () {
    test('returns null when message is empty', () {
      expect(FriendInputValidator.requestMessage('   '), isNull);
    });

    test('returns error when message exceeds max length', () {
      final message = 'a' * (FriendFieldRules.requestMessageMaxLength + 1);

      expect(
        FriendInputValidator.requestMessage(message),
        '친구 요청 메시지는 ${FriendFieldRules.requestMessageMaxLength}자 이하여야 합니다.',
      );
    });
  });

  group('FriendInputValidator.searchQuery', () {
    test('returns error when query is blank', () {
      expect(FriendInputValidator.searchQuery('   '), '검색어를 입력해 주세요.');
    });

    test('returns null when query has text', () {
      expect(FriendInputValidator.searchQuery('alice'), isNull);
    });
  });
}
