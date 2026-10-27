import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aimm/core/l10n/app_localizations.dart';
import 'package:aimm/features/control/providers/mask_controller.dart';
import 'package:aimm/features/profile/presentation/profile_page.dart';
import 'package:aimm/features/profile/presentation/subpages/user_manual_page.dart';

Widget buildTestableWidget({required Widget child, Locale locale = const Locale('zh', 'CN')}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MaskController()),
    ],
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('UserManualPage Tests', () {
    testWidgets('Renders all 6 sections in Simplified Chinese (zh_CN)', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: const UserManualPage(),
          locale: const Locale('zh', 'CN'),
        ),
      );
      await tester.pumpAndSettle();

      // Header
      expect(find.text('用户手册'), findsOneWidget);
      expect(find.text('智能美肤美体仪 ｜ 官方操作手册与技术规范'), findsOneWidget);

      // Section 1
      expect(find.text('1. 运作模式与效能'), findsOneWidget);
      expect(find.text('面部精准护理模式'), findsOneWidget);
      expect(find.text('身体塑形与复合程序'), findsOneWidget);
      expect(find.text('焕活更新'), findsOneWidget);
      expect(find.text('紧致抗老'), findsOneWidget);

      // Section 2
      expect(find.text('2. 设备结构图解'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      // Section 3
      expect(find.text('3. 指示灯状态说明'), findsOneWidget);
      expect(find.text('红灯常亮'), findsOneWidget);
      expect(find.text('绿灯常亮'), findsOneWidget);

      // Switch to body modes tab
      await tester.tap(find.text('身体塑形与复合程序'));
      await tester.pumpAndSettle();

      expect(find.text('舒展放松'), findsOneWidget);
      expect(find.text('综合复合模式'), findsOneWidget);

      // Scroll down to see remaining sections
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // Section 4
      expect(find.text('4. 专属 App 下载与操作步骤'), findsOneWidget);
      expect(find.text('官方专属 App 下载'), findsOneWidget);

      // Scroll further down
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // Section 5
      expect(find.text('5. 常见问题与排除'), findsOneWidget);
      expect(find.text('Q1: App 搜索不到主机设备？'), findsOneWidget);

      // Section 6
      expect(find.text('6. 安全规范与禁忌症'), findsOneWidget);
      expect(find.text('安全操作注意事项'), findsOneWidget);
      expect(find.text('禁忌症对象（严禁使用）'), findsOneWidget);
    });

    testWidgets('Renders all sections in Traditional Chinese (zh_TW)', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: const UserManualPage(),
          locale: const Locale('zh', 'TW'),
        ),
      );
      await tester.pumpAndSettle();

      // Header in Traditional Chinese
      expect(find.text('使用者手冊'), findsOneWidget);
      expect(find.text('智能美膚美體儀 ｜ 官方使用者操作手冊與技術規範'), findsOneWidget);
      expect(find.text('1. 運作模式與效能'), findsOneWidget);
      expect(find.text('面部精準護理模式'), findsOneWidget);
      expect(find.text('煥活更新'), findsOneWidget);
    });

    testWidgets('Renders all sections in English (en)', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: const UserManualPage(),
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      // Header in English
      expect(find.text('User Manual'), findsOneWidget);
      expect(find.text('1. Functional Treatment Modes'), findsOneWidget);
      expect(find.text('Smart Face Modes'), findsOneWidget);
      expect(find.text('Smart Body Modes'), findsOneWidget);
      expect(find.text('Rejuvenating'), findsOneWidget);
    });

    testWidgets('ProfilePage helpCenter menu navigates to UserManualPage', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: const ProfilePage(),
          locale: const Locale('zh', 'CN'),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on 帮助中心
      final helpCenterItem = find.text('帮助中心');
      expect(helpCenterItem, findsOneWidget);

      await tester.tap(helpCenterItem);
      await tester.pumpAndSettle();

      // Should be on UserManualPage
      expect(find.byType(UserManualPage), findsOneWidget);
      expect(find.text('用户手册'), findsOneWidget);
    });
  });
}
