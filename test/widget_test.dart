import 'package:flutter_test/flutter_test.dart';

import 'package:aurum/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AurumApp());

    // Verify that our app bar title is found
    expect(find.text('Aurum'), findsOneWidget);
  });
}
