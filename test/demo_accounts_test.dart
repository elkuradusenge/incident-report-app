import 'package:campus_incident_app/core/theme/app_theme.dart';
import 'package:campus_incident_app/providers/auth_provider.dart';
import 'package:campus_incident_app/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'helpers/fakes.dart';

void main() {
  testWidgets('tapping a demo account fills the email and password fields', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final FakeAuthProvider auth = FakeAuthProvider();
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: auth,
        child: MaterialApp(theme: AppTheme.light, home: const LoginScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('e.kuradusen@alustudent.com'), findsOneWidget);
    expect(find.text('Staff@123'), findsOneWidget);

    await tester.tap(find.text('e.kuradusen@alustudent.com'));
    await tester.pump();

    final List<EditableText> fields = tester
        .widgetList<EditableText>(find.byType(EditableText))
        .toList();
    expect(fields[0].controller.text, 'e.kuradusen@alustudent.com');
    expect(fields[1].controller.text, 'Student@123');
  });
}
