import 'package:domodachi/features/auth/data/mapper/auth_user_mapper.dart';
import 'package:domodachi/features/auth/data/model/auth_user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthUserModelMapper', () {
    test('maps data model to domain entity', () {
      const model = AuthUserModel(
        id: 'user-1',
        email: 'hello@domodachi.app',
        displayName: 'Domo',
        emailVerified: true,
        profileCompleted: true,
      );

      final entity = model.toAuthUser();

      expect(entity.id, 'user-1');
      expect(entity.email, 'hello@domodachi.app');
      expect(entity.displayName, 'Domo');
      expect(entity.emailVerified, isTrue);
      expect(entity.profileCompleted, isTrue);
      expect(entity.isProfileComplete, isTrue);
    });
  });
}
