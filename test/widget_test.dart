import 'package:flutter_test/flutter_test.dart';
import 'package:aimm/app.dart';

void main() {
  testWidgets('SmartMaskApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartMaskApp());
    await tester.pump(const Duration(milliseconds: 200));

    // Verify Control Tab and Mode Selection are rendered
    expect(find.text('Mode Selection'), findsOneWidget);
  });
}
