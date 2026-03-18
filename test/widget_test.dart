// Basic smoke test for Snake Game
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_modern/main.dart';

void main() {
  testWidgets('Snake game smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SnakeApp());
    await tester.pumpAndSettle();

    // Verify the app loads with the title
    expect(find.text('SNAKE'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
  });
}
