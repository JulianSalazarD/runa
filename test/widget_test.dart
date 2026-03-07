import 'package:flutter_test/flutter_test.dart';
import 'package:runa/main.dart';

void main() {
  testWidgets('RunaApp renders the smoke screen', (WidgetTester tester) async {
    await tester.pumpWidget(const RunaApp());
    // The smoke screen shows this text while the async test runs.
    expect(find.text('Running smoke test…'), findsOneWidget);
  });
}
