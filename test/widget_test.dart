// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:catatan_ibay/main.dart';
import 'package:catatan_ibay/services/storage_service.dart';

void main() {
  testWidgets('App builds and shows main sections', (WidgetTester tester) async {
    // Initialize storage (Hive) like main() does so app can access settings and today's entry
    await StorageService().init();

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // App title
    expect(find.text('Catatan Ibay'), findsOneWidget);
    // Check presence of Today page components
    expect(find.textContaining('To Do Hari Ini'), findsOneWidget);
    expect(find.textContaining('Daily Notes'), findsOneWidget);
  });
}
