import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_sample_apps/main.dart';

void main() {
  testWidgets('Home screen offers sender and receiver', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Share my location'), findsOneWidget);
    expect(find.text('Track a location'), findsOneWidget);
  });
}
