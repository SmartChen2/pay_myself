// Basic smoke test: ensure the app builds and renders the tasks page.

import 'package:flutter_test/flutter_test.dart';

import 'package:paymyself/main.dart';

void main() {
  testWidgets('App renders tasks page', (WidgetTester tester) async {
    await tester.pumpWidget(const PayMeApp());
    await tester.pump();
    expect(find.text('任务'), findsWidgets);
  });
}
