import 'package:flutter_test/flutter_test.dart';
import 'package:aimm/app.dart';

void main() {
  testWidgets('SmartMaskApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartMaskApp());
    await tester.pumpAndSettle();

    // Verify Control Tab and Beauty Hub are rendered
    expect(find.text('Beauty Hub'), findsOneWidget);
  });
}
