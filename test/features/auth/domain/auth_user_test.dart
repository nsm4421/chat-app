import 'package:domodachi/features/auth/domain/entity/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthUser', () {
    test('isProfileComplete is true only when flag and display name exist', () {
      const completeUser = AuthUser(
        id: 'user-1',
        email: 'hello@domodachi.app',
        displayName: 'Domo',
        profileCompleted: true,
      );
      const missingName = AuthUser(
        id: 'user-2',
        email: 'hello@domodachi.app',
        profileCompleted: true,
      );
      const incomplete = AuthUser(
        id: 'user-3',
        email: 'hello@domodachi.app',
        displayName: 'Domo',
      );

      expect(completeUser.isProfileComplete, isTrue);
      expect(missingName.isProfileComplete, isFalse);
      expect(incomplete.isProfileComplete, isFalse);
    });
  });
}
