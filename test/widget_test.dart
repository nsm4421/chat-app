import 'package:domodachi/features/auth/presentation/pages/auth_landing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders auth landing actions', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AuthLandingPage()));

    expect(find.text('Domodachi 시작하기'), findsOneWidget);
    expect(find.text('이메일로 로그인'), findsOneWidget);
    expect(find.text('새 계정 만들기'), findsOneWidget);
  });
}
