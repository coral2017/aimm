import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:aimm/core/l10n/app_localizations.dart';
import 'package:aimm/core/widgets/app_feedback.dart';
import 'package:aimm/features/control/providers/mask_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget createTestApp(Widget child, {Locale locale = const Locale('zh', 'CN')}) {
  return ChangeNotifierProvider(
    create: (_) => MaskController(),
    child: MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: locale,
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppFeedback Tests', () {
    testWidgets('AppToast.showGoldenToast shows Plan A floating golden capsule with pure text and no icons', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (context) => Column(
              children: [
                ElevatedButton(
                  onPressed: () => AppToast.showGoldenToast(
                    context,
                    context.tr('deviceNotConnected'),
                  ),
                  child: const Text('Disconnected Toast'),
                ),
                ElevatedButton(
                  onPressed: () => AppToast.showGoldenToast(
                    context,
                    context.tr('pleaseSelectMode'),
                  ),
                  child: const Text('No Mode Toast'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Trigger disconnected golden toast
      await tester.tap(find.text('Disconnected Toast'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('设备未连接'), findsOneWidget);
      // Verify NO icons are rendered in the golden toast (pure text)
      expect(find.byIcon(Icons.bluetooth_disabled_rounded), findsNothing);

      // Trigger no mode golden toast (should seamlessly replace)
      await tester.tap(find.text('No Mode Toast'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('请先选择护理模式'), findsOneWidget);
      expect(find.byIcon(Icons.touch_app_outlined), findsNothing);
      expect(find.text('设备未连接'), findsNothing);

      // Drain timer
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('AppToast.showSuccess shows floating unpair toast', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => AppToast.showSuccess(context, context.tr('deviceUnpaired')),
              child: const Text('Show Success Toast'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Success Toast'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('设备已解除配对'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('Pair and Unpair terminology consistency across languages', (tester) async {
      // English
      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (context) => Column(
              children: [
                Text('Pair: ${context.tr('pairDevice')}'),
                Text('Unpair: ${context.tr('unpairDevice')}'),
                Text('Unpaired: ${context.tr('deviceUnpaired')}'),
              ],
            ),
          ),
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pair: Pair Device'), findsOneWidget);
      expect(find.text('Unpair: Unpair Device'), findsOneWidget);
      expect(find.text('Unpaired: Device Unpaired'), findsOneWidget);

      // Chinese Simplified
      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (context) => Column(
              children: [
                Text('Pair: ${context.tr('pairDevice')}'),
                Text('Unpair: ${context.tr('unpairDevice')}'),
                Text('Unpaired: ${context.tr('deviceUnpaired')}'),
              ],
            ),
          ),
          locale: const Locale('zh', 'CN'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pair: 配对设备'), findsOneWidget);
      expect(find.text('Unpair: 解除配对'), findsOneWidget);
      expect(find.text('Unpaired: 设备已解除配对'), findsOneWidget);
    });
  });
}
