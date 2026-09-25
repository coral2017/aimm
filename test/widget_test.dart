import 'package:flutter_test/flutter_test.dart';
import 'package:aimm/app.dart';

void main() {
  testWidgets('SmartMaskApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartMaskApp());
    await tester.pumpAndSettle();

    // Verify Control Tab and Treatment Area are rendered
    expect(find.text('Treatment Area'), findsOneWidget);
  });
}
